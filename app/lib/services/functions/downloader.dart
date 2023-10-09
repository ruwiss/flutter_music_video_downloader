import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:melotune/locator.dart';
import 'package:melotune/services/extensions/string_extensions.dart';
import 'package:melotune/services/functions/firebase_analytics.dart';
import 'package:melotune/services/functions/local_db.dart';
import 'package:melotune/services/models/download_model.dart';
import 'package:melotune/services/models/playlist_model.dart';
import 'package:melotune/services/models/ringtone_model.dart';
import 'package:melotune/services/providers/download_provider.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:melotune/services/providers/home_provider.dart';
import 'package:melotune/services/providers/ringtones_provider.dart';
import 'package:melotune/utils/strings.dart';
import 'package:melotune/widgets/features/home/media_action_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Downloader {
  // Dio Zaman Aşımı Ayarları
  final _dio = Dio(BaseOptions(
      sendTimeout: const Duration(minutes: 10),
      connectTimeout: const Duration(minutes: 10),
      receiveTimeout: const Duration(minutes: 10)));

  // Hata oluşursa bile devam etmeye çalış
  Downloader() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) => handler.next(options),
      onError: (options, handler) => handler.next(options),
      onResponse: (options, handler) => handler.next(options),
    ));
  }

  // İzin işlemleri
  Future<bool> storagePermission() async {
    PermissionStatus permissionStatus = await Permission.storage.request();
    if (permissionStatus.isDenied) {
      permissionStatus = await Permission.mediaLibrary.request();
    }

    if (!permissionStatus.isGranted) {
      await Fluttertoast.showToast(
          msg: KStrings.permissionSettings,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      await openAppSettings();
      return false;
    } else {
      return true;
    }
  }

  void download({
    required DownloadModel downloadModel,
    required PlayListItemModel playListItemModel,
  }) async {
    if (!await storagePermission()) return;
    locator.get<LocalDB>().checkForAfterDownloadsAction();
    final homeProvider = locator.get<HomeProvider>();

    if (homeProvider.getAppSetting("downloadFromApi").parseBool()) {
      downloadFromApi(
          downloadModel: downloadModel, playListItemModel: playListItemModel);
    } else {
      downlaodFromStream(
          downloadModel: downloadModel, playListItemModel: playListItemModel);
    }
  }

  void downlaodFromStream({
    required DownloadModel downloadModel,
    required PlayListItemModel playListItemModel,
  }) async {
    final downloadProvider = locator.get<DownloadProvider>();

    final bool isMp3 = downloadModel.type == DownloadType.mp3;
    final String ytId = downloadModel.ytId;
    final String name = playListItemModel.title.reFormatTitle();
    final mediaType = isMp3 ? MediaType.mp3 : MediaType.mp4;

    late StreamManifest manifest;

    final yt = YoutubeExplode();
    try {
      manifest = await yt.videos.streamsClient.getManifest(ytId);
    } catch (e) {
      downloadProvider.changeItemStatus(ytId, mediaType, 0, ItemStatus.failed);
      return;
    }

    final videoQualityList = manifest.muxed.sortByVideoQuality();

    // Düşük Kalite mp4 & Yüksek Kalite mp3
    final streamInfo = isMp3
        ? manifest.audioOnly.withHighestBitrate()
        : videoQualityList.length > 3
            ? videoQualityList[2]
            : videoQualityList.length > 2
                ? videoQualityList[1]
                : videoQualityList.last;
    final size = streamInfo.size.totalBytes;

    final Directory saveTempDir = await getTemporaryDirectory();
    downloadProvider.addItemToQueue(DownloadModel(
        ytId: ytId,
        type: isMp3 ? DownloadType.mp3 : DownloadType.mp4,
        status: ItemStatus.waiting,
        progress: 0));

    File file = File("${saveTempDir.path}/$ytId.${isMp3 ? 'mp3' : 'mp4'}");

    var count = 0;
    final stream = yt.videos.streamsClient.get(streamInfo);
    var output = file.openWrite(mode: FileMode.writeOnlyAppend);

    // Stream üzerinden dosyayı kaydetme
    await for (final data in stream) {
      count += data.length;
      double val = ((count / size) * 100);

      downloadProvider.changeItemStatus(
          ytId, mediaType, val.round(), ItemStatus.downloading);
      output.add(data);
      if (val == 100.0) {
        await output.flush();
        await output.close();

        AnalyticsService.analytics.logEvent(name: "download", parameters: {
          "type": isMp3 ? "mp3" : "mp4",
          "ytId": ytId,
          "title": name,
        });

        file = await file.rename(file.path.replaceAll(ytId, name));

        // İndirilenleri hafızaya kaydetme
        final LocalDB localDB = locator.get<LocalDB>();
        isMp3 ? localDB.saveMp3(ytId) : localDB.saveMp4(ytId);

        // İndirilen medyayı sisteme bildirme
        // Videolar veya Müzikler bölümünde yer alması için
        MediaStore.appFolder = "/";
        await MediaStore()
            .saveFile(
                tempFilePath: file.path,
                relativePath: "/",
                dirType: isMp3 ? DirType.audio : DirType.video,
                dirName: isMp3 ? DirName.music : DirName.movies)
            .then((value) => log("MediaStore Status : $value"));

        // MediaStore kaydı sonrası temp dosyası silinir
        await file.delete();

        downloadProvider.changeItemStatus(
            ytId, mediaType, 100, ItemStatus.succeeded);

        Fluttertoast.showToast(
            msg: "$name ${KStrings.downloadedToast}",
            toastLength: Toast.LENGTH_SHORT);
      }
    }
  }

  void downloadFromApi(
      {required DownloadModel downloadModel,
      required PlayListItemModel playListItemModel}) async {
    final bool isMp3 = downloadModel.type == DownloadType.mp3;
    final String ytId = downloadModel.ytId;
    final String name = playListItemModel.title.reFormatTitle();

    final url = KHost.getDownloadUrl(ytId);

    final Directory saveTempDir = await getTemporaryDirectory();

    final downloadProvider = locator.get<DownloadProvider>();
    downloadProvider.addItemToQueue(DownloadModel(
        ytId: ytId,
        type: isMp3 ? DownloadType.mp3 : DownloadType.mp4,
        status: ItemStatus.waiting,
        progress: 0));

    int progress = 0;

    File saveMp4TempFile = File("${saveTempDir.path}/$ytId.mp4");
    File saveMp3TempFile = File("${saveTempDir.path}/$ytId.mp3");

    final MediaType mediaType = isMp3 ? MediaType.mp3 : MediaType.mp4;
    late Response response;
    // İndirme işlemi
    try {
      response = await _dio.get(
        url,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            validateStatus: (status) => status! < 500),
        onReceiveProgress: (count, total) {
          progress = ((count / total) * 100).floor();
          if (downloadProvider.getModel(ytId, mediaType).progress != progress) {
            downloadProvider.changeItemStatus(
                ytId, mediaType, progress, ItemStatus.downloading);
          }
        },
      );

      // indirme hatası
      if (response.statusCode != 200) {
        downloadProvider.changeItemStatus(
            ytId, mediaType, progress, ItemStatus.failed);
      } else {
        AnalyticsService.analytics.logEvent(name: "download", parameters: {
          "type": isMp3 ? "mp3" : "mp4",
          "ytId": ytId,
          "title": name,
        });
      }
    } catch (e) {
      downloadProvider.changeItemStatus(
          ytId, mediaType, progress, ItemStatus.failed);
      log(e.toString());
    }

    try {
      // İndirilen içeriği senkron olarak dosyaya yazma
      RandomAccessFile raf = saveMp4TempFile.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      /// Yeniden adlandırme ve Dönüştürme ///
      downloadProvider.changeItemStatus(
          ytId, mediaType, 100, ItemStatus.converting);
      if (isMp3) {
        // Mp4 dosyasını Mp3'e çevirme
        await FFmpegKit.execute(
            '-i ${saveMp4TempFile.path} ${saveMp3TempFile.path}');
        await saveMp4TempFile.delete();
        // Dosya ismini şarkı ismine göre ayarla (kaydederken özel karakteri sorununa yönelik)
        saveMp3TempFile = await saveMp3TempFile
            .rename(saveMp3TempFile.path.replaceAll(ytId, name));
      } else {
        saveMp4TempFile = await saveMp4TempFile
            .rename(saveMp4TempFile.path.replaceAll(ytId, name));
      }

      // İndirilenleri hafızaya kaydetme
      final LocalDB localDB = locator.get<LocalDB>();
      isMp3 ? localDB.saveMp3(ytId) : localDB.saveMp4(ytId);

      // İndirilen medyayı sisteme bildirme
      // Videolar veya Müzikler bölümünde yer alması için
      MediaStore.appFolder = "/";
      await MediaStore()
          .saveFile(
              tempFilePath: isMp3 ? saveMp3TempFile.path : saveMp4TempFile.path,
              dirType: isMp3 ? DirType.audio : DirType.video,
              dirName: isMp3 ? DirName.music : DirName.movies)
          .then((value) => log("MediaStore Status : $value"));

      // MediaStore kaydı sonrası temp dosyası silinir
      isMp3 ? await saveMp3TempFile.delete() : await saveMp4TempFile.delete();

      downloadProvider.changeItemStatus(
          ytId, mediaType, 100, ItemStatus.succeeded);
      Fluttertoast.showToast(
          msg: "$name ${KStrings.downloadedToast}",
          toastLength: Toast.LENGTH_SHORT);
    } catch (e) {
      downloadProvider.changeItemStatus(ytId, mediaType, 0, ItemStatus.failed);
      log("Problem : $e");
    }
  }

  Future<bool> downloadRingtone({required RingtoneModel ringtoneModel}) async {
    final String name = ringtoneModel.title.reFormatTitle();

    final url = KHost.playRingtone(ringtoneModel.id);
    final Directory saveTempDir = await getTemporaryDirectory();

    final ringtonesProvider = locator.get<RingtonesProvider>();
    var downloadModel = RingtoneDownloadModel(
        ringtoneModel.id, 0, RingtoneDownloadStatus.waiting);

    ringtonesProvider.setDownloadModel(downloadModel);

    File saveMp3TempFile = File("${saveTempDir.path}/$name.mp3");

    late Response response;
    // İndirme işlemi
    try {
      response = await _dio.get(
        url,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            validateStatus: (status) => status! < 500),
        onReceiveProgress: (count, total) {
          downloadModel.progress = ((count / total) * 100).floor();
          if (downloadModel.status != RingtoneDownloadStatus.downloading) {
            downloadModel.status = RingtoneDownloadStatus.downloading;
          }
          ringtonesProvider.setDownloadModel(downloadModel);
        },
      );

      // indirme hatası
      if (response.statusCode == 200) {
        AnalyticsService.analytics.logEvent(name: "download", parameters: {
          "type": "ringtone",
          "title": name,
        });
      } else {
        downloadModel.status = RingtoneDownloadStatus.error;
        ringtonesProvider.setDownloadModel(downloadModel);
        return false;
      }
    } catch (e) {
      downloadModel.status = RingtoneDownloadStatus.error;
      ringtonesProvider.setDownloadModel(downloadModel);
      log(e.toString());
      return false;
    }

    try {
      // İndirilen içeriği senkron olarak dosyaya yazma
      RandomAccessFile raf = saveMp3TempFile.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      // İndirilenleri hafızaya kaydetme
      final LocalDB localDB = locator.get<LocalDB>();
      localDB.saveRingtone(ringtoneModel.id);

      // İndirilen medyayı sisteme bildirme
      // Videolar veya Müzikler bölümünde yer alması için
      MediaStore.appFolder = "/";
      await MediaStore()
          .saveFile(
            relativePath: "Ringtones",
            tempFilePath: saveMp3TempFile.path,
            dirType: DirType.audio,
            dirName: DirName.music,
          )
          .then((value) => log("MediaStore Status : $value"));

      // MediaStore kaydı sonrası temp dosyası silinir
      await saveMp3TempFile.delete();

      downloadModel.status = RingtoneDownloadStatus.success;
      ringtonesProvider.setDownloadModel(downloadModel);
      Fluttertoast.showToast(
          msg: '${KStrings.downloadedToast}\nMusic/Ringtones',
          toastLength: Toast.LENGTH_SHORT);
    } catch (e) {
      downloadModel.status = RingtoneDownloadStatus.error;
      ringtonesProvider.setDownloadModel(downloadModel);
      log("Problem : $e");
      return false;
    }
    return true;
  }
}

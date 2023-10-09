import 'package:get_it/get_it.dart';
import 'package:melotune/services/backend/data_service.dart';
import 'package:melotune/services/functions/download_list.dart';
import 'package:melotune/services/functions/downloader.dart';
import 'package:melotune/services/functions/local_db.dart';
import 'package:melotune/services/providers/download_provider.dart';
import 'package:melotune/services/providers/downloads_provider.dart';
import 'package:melotune/services/providers/home_provider.dart';
import 'package:melotune/services/providers/player_provider.dart';
import 'package:melotune/services/providers/ringtones_provider.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<HomeProvider>(HomeProvider());
  locator.registerSingleton<DownloadProvider>(DownloadProvider());
  locator.registerSingleton<PlayerProvider>(PlayerProvider());
  locator.registerSingleton<DownloadsProvider>(DownloadsProvider());
  locator.registerSingleton<RingtonesProvider>(RingtonesProvider());
  locator.registerSingleton<DataService>(DataService());
  locator.registerSingleton<Downloader>(Downloader());
  locator.registerSingleton<LocalDB>(LocalDB());
  locator.registerSingleton<DownloadList>(DownloadList());
}

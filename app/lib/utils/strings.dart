import 'package:melotune/services/functions/translate.dart';

class KHost {
  static const String host = "http://10.0.2.2:5000";
  static String getPlaylistsUrl = "$host/liste/${getAppLanguage()}";
  static String getAppSettings = "$host/settings";
  static String getRingtones = "$host/ringtones";
  static String getDownloadUrl(String ytId) => "$host/yt/$ytId";
  static String getListenUrl(String ytId) => "$host/dinle/$ytId";
  static String getSearchUrl(String query) => "$host/ara/v2/$query";
  static String getAutoCompleteUrl(String query) => "$host/complete/$query";
  static String playRingtone(int id) => "$host/ringtones/$id";
}

class KStrings {
  static const String playStoreLink =
      "https://play.google.com/store/apps/details?id=com.rw.melotune";
  static String youtubeUrl(String id) => "https://www.youtube.com/watch?v=$id";
  static const String appVersion = "2.5.0";
  static String downloadsPage = translate("İndirilenler", "Downloads");
  static String ringtonesPage = translate("Zil Sesleri", "Ringtones");
  static String searchBtn = translate("Ara", "Search");
  static String searchHint =
      translate("Bir şeyler yaz..", "Song or artist name");
  static String permissionSettings = translate(
      "Öncelikle uygulamaya izin vermelisiniz",
      "First, allow storage permission");
  static String downloadedToast = translate("İndirildi", "Downloaded");
  static String listenError =
      translate("Bir sorun oluştu", "Something went wrong");
  static String searchInfo = translate("İçin Sonuçlar", "Results");
  static String noResults = translate("Sonuç Yok", "No Results");
  static String musicsTab = translate("Müzikler", "Musics");
  static String videosTab = translate("Videolar", "Videos");
  static String playlistTab = translate("Listelerim", "Playlists");
  static String noItem = translate("Henüz bir şey yok", "No Item");
  static String loadMore = translate("Daha Fazla", "Load More");
  static final String menuTitle = translate(" Menü ", " Menu ");
  static final String downloadMenu = translate("İndirilenler", "Downloads");
  static final String playlistMenu = translate("Listelerim", "Playlists");
  static final String voteMenu = translate("Puan Ver", "Vote App");
  static final String waitingAd = translate("Reklam Bekleniyor", "Waiting Ad");
  static final String loading = translate("Yükleniyor", "Loading");
  static final String nextMusic =
      translate("Sıradaki oynatılıyor", "Next music playing");

  static final String internetProblem = translate(
      "İnternet bağlantın yok gibi görünüyor.",
      "I think you don't have an internet connection.");
  static final String reconnect = translate("Tekrar Bağlan", "Reconnect");
  static final String addToPlayList =
      translate("Listelerime Ekle", "Add to PlayList");
  static final String selectPlaylist =
      translate("Liste Seç", "Select a PlayList");
  static final String createPlayListButton =
      translate("Yeni Oluştur", "Create New");

  static final String playListName = translate("Liste ismi", "Playlist name");
  static final String addedToPlayList =
      translate("Listeye Eklendi", "Added to Playlist");
  static final String alreadyAdded =
      translate("Zaten Eklenmiş", "Already Added");
  static final String createPlaylistInfo = translate(
      "Liste oluşturmak ve müzik eklemek için herhangi bir müziğin üzerine uzun dokunun.",
      "Tap and hold on any music to create a playlist and add music.");

  static final String confirm = translate("Onayla", "Confirm");
  static final String cancel = translate("İptal", "Cancel");
  static final String areYouSure = translate("Emin misiniz?", "Are you sure?");
  static final String deletePlayListInfo = translate(
      "Oynatma listeniz silinecek.", "Your playlist will be deleted.");
  static final String deleteMusicFromPlayListInfo = translate(
      "Müzik, oynatma listesinden silinecek.",
      "The music will be deleted from the playlist.");
  static final String deletedPlaylist =
      translate("Listeniz silindi", "Has been deleted.");
  static final String deletedMusicFromPlayList =
      translate("Başarıyla silindi", "Successfully deleted");
  static final String noHavePlayList = translate(
      "Henüz liste oluşturmadın.", "You haven't created a playlist yet.");
}

class KAppId {
  static const String interstitalAd1 = "";
  static const String interstitalAd2 = "";
  static const String bannerAd1 = "";
  static const String onesignalAppId = "";
}

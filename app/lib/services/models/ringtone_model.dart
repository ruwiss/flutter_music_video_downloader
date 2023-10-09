enum RingtoneDownloadStatus { waiting, downloading, success, error}

class RingtoneModel {
  RingtoneModel(this.id, this.image, this.title);
  final int id;
  final String image;
  final String title;

  RingtoneModel.fromJson(Map json)
      : id = json['id'],
        image = json['image'],
        title = json['title'];
}

class RingtoneDownloadModel {
  RingtoneDownloadModel(this.id, this.progress, this.status);
  final int id;
   int progress;
  RingtoneDownloadStatus status;
}

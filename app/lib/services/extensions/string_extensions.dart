// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

extension StringExtensions on String {
  String reFormatTitle() {
    final text = replaceAll(RegExp(r'[.*_*|?\\\/(){}\[\]%!><£#$½"^&:~;`]'), '');
    return p.basename(text).replaceAll("  ", " ");
  }

  String getNameFromPath() {
    return split("/").last.replaceAll(".mp3", "").replaceAll(".mp4", "");
  }

  bool parseBool() => toLowerCase() == 'true';
}

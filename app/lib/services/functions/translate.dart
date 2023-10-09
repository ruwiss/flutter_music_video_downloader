import 'dart:ui' as ui;

// ignore: deprecated_member_use
String getAppLanguage() => ui.window.locale.languageCode;

String translate(String tr, String en) {
  if (getAppLanguage() == "tr") {
    return tr;
  } else {
    return en;
  }
}

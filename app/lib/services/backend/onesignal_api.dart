import 'package:melotune/services/functions/translate.dart';
import 'package:melotune/utils/strings.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalApi {
  static Future setupOneSignal() async {
    final String? deviceId = await PlatformDeviceId.getDeviceId;
    final String deviceLang = getAppLanguage();

    OneSignal.initialize(KAppId.onesignalAppId);
    await OneSignal.Notifications.requestPermission(true);

    await OneSignal.login(deviceId!);
    await OneSignal.User.addTags(
        {"deviceId": deviceId, "deviceLang": deviceLang});
  }
}

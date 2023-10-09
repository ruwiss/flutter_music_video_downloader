import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:platform_device_id/platform_device_id.dart';

class AnalyticsService {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver analyticsObserver =
      FirebaseAnalyticsObserver(analytics: analytics);

  static void setUser() {
    PlatformDeviceId.getDeviceId
        .then((value) => analytics.setUserId(id: value));
  }
}

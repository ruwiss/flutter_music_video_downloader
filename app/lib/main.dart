import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:melotune/locator.dart';
import 'package:melotune/pages/downloads_page.dart';
import 'package:melotune/pages/playlists_page.dart';
import 'package:melotune/pages/ringtones_page.dart';
import 'package:melotune/services/backend/onesignal_api.dart';
import 'package:melotune/services/functions/firebase_analytics.dart';
import 'package:melotune/services/providers/download_provider.dart';
import 'package:melotune/services/providers/downloads_provider.dart';
import 'package:melotune/services/providers/home_provider.dart';
import 'package:melotune/services/providers/player_provider.dart';
import 'package:melotune/services/providers/ringtones_provider.dart';
import 'package:melotune/utils/colors.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AnalyticsService.analytics.logAppOpen();
  MobileAds.instance.initialize();
  OneSignalApi.setupOneSignal();
  setupLocator();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<HomeProvider>(
          create: (context) => locator.get<HomeProvider>()),
      ChangeNotifierProvider<DownloadProvider>(
          create: (context) => locator.get<DownloadProvider>()),
      ChangeNotifierProvider<PlayerProvider>(
          create: (context) => locator.get<PlayerProvider>()),
      ChangeNotifierProvider<DownloadsProvider>(
          create: (context) => locator.get<DownloadsProvider>()),
      ChangeNotifierProvider<RingtonesProvider>(
          create: (context) => locator.get<RingtonesProvider>()),
    ],
    child: const MyApp(),
  ));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [AnalyticsService.analyticsObserver],
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: KColors.appPrimary,
        fontFamily: "WorkSans",
        textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 18),
            bodyMedium: TextStyle(fontSize: 17),
            bodySmall: TextStyle(fontSize: 16),
            labelLarge: TextStyle(fontSize: 18),
            titleMedium: TextStyle(fontSize: 19),
            titleLarge: TextStyle(fontSize: 27, fontWeight: FontWeight.normal)),
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const HomePage(),
        "/downloads": (context) => const DownloadsPage(),
        "/playLists": (context) => const PlayListsPage(),
        "/ringtones": (context) => const RingtonesPage(),
      },
    );
  }
}

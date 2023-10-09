import 'package:admin_panel/locator.dart';
import 'package:admin_panel/services/providers/base_provider.dart';
import 'package:admin_panel/services/providers/block_provider.dart';
import 'package:admin_panel/services/providers/playlist_provider.dart';
import 'package:admin_panel/services/providers/ringtones_provider.dart';
import 'package:flutter/material.dart';
import 'pages/home/base.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<BaseProvider>(
          create: (context) => locator.get<BaseProvider>()),
      ChangeNotifierProvider<BlockProvider>(
          create: (context) => locator.get<BlockProvider>()),
      ChangeNotifierProvider<PlaylistProvider>(
          create: (context) => locator.get<PlaylistProvider>()),
      ChangeNotifierProvider<RingtonesProvider>(
          create: (context) => locator.get<RingtonesProvider>())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => HomePage(),
      },
    );
  }
}

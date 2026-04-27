import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Windows/macOS/web 미설정 환경에서는 앱이 계속 동작하도록 둔다.
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const white = Colors.white;
    const black = Colors.black;
    final lightScheme = SeedColorScheme.fromSeeds(
      brightness: Brightness.light,
      primaryKey: const Color(0xFF111111),
      secondaryKey: const Color(0xFF222222),
      surface: white,
      onSurface: black,
    );

    return GetMaterialApp(
      title: "광고없는제과제빵기출회독",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: white,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: black,
          displayColor: black,
        ),
      ),
    );
  }
}

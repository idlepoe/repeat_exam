import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
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

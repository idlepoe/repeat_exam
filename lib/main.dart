import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';

import 'package:get/get.dart';

import 'app/data/services/storage_service.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialThemeMode = await StorageService.loadThemeMode();
  runApp(MyApp(initialThemeMode: initialThemeMode));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialThemeMode});

  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    final lightScheme = SeedColorScheme.fromSeeds(
      brightness: Brightness.light,
      primaryKey: const Color(0xFF111111),
      secondaryKey: const Color(0xFF222222),
      surface: Colors.white,
      onSurface: Colors.black,
    );

    final darkScheme = SeedColorScheme.fromSeeds(
      brightness: Brightness.dark,
      primaryKey: const Color(0xFF111111),
      secondaryKey: const Color(0xFF222222),
    );

    return GetMaterialApp(
      title: "광고없는제과제빵기출회독",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      themeMode: initialThemeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: lightScheme.surface,
        extensions: const [AppColors.light],
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: lightScheme.onSurface,
          displayColor: lightScheme.onSurface,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: darkScheme.surface,
        extensions: const [AppColors.dark],
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: darkScheme.onSurface,
          displayColor: darkScheme.onSurface,
        ),
      ),
    );
  }
}

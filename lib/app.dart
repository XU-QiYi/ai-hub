import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme_config.dart';
import 'providers/theme_provider.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'AI Hub',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.background(isDark: false),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.background(isDark: false),
              foregroundColor: AppColors.primaryText(isDark: false),
              elevation: 0,
            ),
            cardColor: AppColors.cardBackground(isDark: false),
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryText(isDark: false),
              surface: AppColors.background(isDark: false),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.background(isDark: true),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.background(isDark: true),
              foregroundColor: AppColors.primaryText(isDark: true),
              elevation: 0,
            ),
            cardColor: AppColors.cardBackground(isDark: true),
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryText(isDark: true),
              surface: AppColors.background(isDark: true),
            ),
          ),
          home: const HomePage(),
          routes: {
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}

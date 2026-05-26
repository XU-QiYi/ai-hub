import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme_config.dart';
import 'providers/theme_provider.dart';
import 'pages/main_shell.dart';
import 'services/update_service.dart';

/// App version, keep in sync with pubspec.yaml version field.
const String appVersion = "1.1.0";

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic>? _availableUpdate;

  @override
  void initState() {
    super.initState();
    _checkUpdateOnStartup();
  }

  void _checkUpdateOnStartup() async {
    final update = await UpdateService().checkForUpdate(appVersion);
    if (mounted && update != null) {
      setState(() => _availableUpdate = update);
    }
  }

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
            scaffoldBackgroundColor: const Color(0xFFF0F2F5),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF0F2F5),
              foregroundColor: Color(0xFF1A1A1A),
              elevation: 0,
            ),
            cardColor: AppColors.cardBackground(isDark: false),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A1A1A),
              surface: Color(0xFFF0F2F5),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF08090D),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF08090D),
              foregroundColor: Color(0xFFFFFFFF),
              elevation: 0,
            ),
            cardColor: AppColors.cardBackground(isDark: true),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFFFFF),
              surface: Color(0xFF08090D),
            ),
          ),
          home: MainShell(
            initialUpdate: _availableUpdate,
            onClearUpdate: () =>
                setState(() => _availableUpdate = null),
          ),
        );
      },
    );
  }
}

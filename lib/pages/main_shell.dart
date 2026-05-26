import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import 'home_page.dart';
import 'settings_page.dart';

class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('卡片')),
      body: const Center(
        child: Text('卡片浏览'),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final Map<String, dynamic>? initialUpdate;
  final VoidCallback? onClearUpdate;

  const MainShell({
    super.key,
    this.initialUpdate,
    this.onClearUpdate,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final pages = [
      const HomePage(),
      const CardPage(),
      SettingsPage(
        initialUpdate: widget.initialUpdate,
        onClearUpdate: widget.onClearUpdate,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: AppColors.primaryText(isDark: isDark),
        unselectedItemColor: AppColors.secondaryText(isDark: isDark),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: '卡片',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}

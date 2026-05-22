import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../config/services_config.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final secondaryColor = AppColors.secondaryText(isDark: isDark);
    final primaryTextColor = AppColors.primaryText(isDark: isDark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '主题',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                ),
                RadioGroup<ThemeMode>(
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setThemeMode(value);
                    }
                  },
                  child: Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        title: const Text('深色'),
                        value: ThemeMode.dark,
                        activeColor: primaryTextColor,
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('浅色'),
                        value: ThemeMode.light,
                        activeColor: primaryTextColor,
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('跟随系统'),
                        value: ThemeMode.system,
                        activeColor: primaryTextColor,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '关于',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('当前版本'),
                  trailing: Text(
                    'v1.0.0',
                    style: TextStyle(color: secondaryColor),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.system_update),
                  title: const Text('检查更新'),
                  onTap: () {
                    debugPrint('check update clicked');
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '数据',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('清除 WebView 缓存'),
                  subtitle: Text(
                    '保留登录状态',
                    style: TextStyle(fontSize: 12, color: secondaryColor),
                  ),
                  onTap: () {
                    debugPrint('clear cache clicked');
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '收录服务',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                ),
                ...aiServices.map((service) => ListTile(
                      leading: Icon(service.icon, color: secondaryColor),
                      title: Text(service.name),
                      subtitle: Text(
                        '网页版: ${service.url}',
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        service.packageName != null
                            ? '客户端: 已配置'
                            : '客户端: 未配置',
                        style: TextStyle(
                          fontSize: 11,
                          color: service.packageName != null
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

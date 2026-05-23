import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app.dart';
import '../config/theme_config.dart';
import '../config/services_config.dart';
import '../providers/theme_provider.dart';
import '../services/update_service.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, dynamic>? initialUpdate;
  final VoidCallback? onClearUpdate;

  const SettingsPage({
    super.key,
    this.initialUpdate,
    this.onClearUpdate,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _channel = MethodChannel('com.aihub.webview');
  bool _isCheckingUpdate = false;

  Widget _buildIcon(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (ext == 'svg') {
      return SvgPicture.asset(path, width: 24, height: 24);
    }
    return Image.asset(path, width: 24, height: 24, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final secondaryColor = AppColors.secondaryText(isDark: isDark);
    final primaryTextColor = AppColors.primaryText(isDark: isDark);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Theme ----
                _sectionHeader('主题', secondaryColor),
                RadioGroup<ThemeMode>(
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) {
                    if (value != null) themeProvider.setThemeMode(value);
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

                // ---- About ----
                _sectionHeader('关于', secondaryColor),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('当前版本'),
                  trailing: Text(
                    'v$appVersion',
                    style: TextStyle(color: secondaryColor),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.system_update),
                  title: const Text('检查更新'),
                  trailing: _isCheckingUpdate
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: _isCheckingUpdate ? null : _handleCheckUpdate,
                ),

                const Divider(height: 1, indent: 16, endIndent: 16),

                // ---- Data ----
                _sectionHeader('数据', secondaryColor),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('清除 WebView 缓存'),
                  subtitle: Text(
                    '保留登录状态',
                    style: TextStyle(fontSize: 12, color: secondaryColor),
                  ),
                  onTap: _handleClearCache,
                ),

                const Divider(height: 1, indent: 16, endIndent: 16),

                // ---- Services ----
                _sectionHeader('收录服务', secondaryColor),
                ...aiServices.map((service) => ListTile(
                      leading: _buildIcon(service.iconPath),
                      title: Text(service.name),
                      subtitle: Text(
                        '网页版: ${service.url}',
                        style: TextStyle(fontSize: 11, color: secondaryColor),
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

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // ---- Update Logic ----

  void _handleCheckUpdate() async {
    setState(() => _isCheckingUpdate = true);

    final update = await UpdateService().checkForUpdate(appVersion);

    if (!mounted) return;
    setState(() => _isCheckingUpdate = false);

    if (update == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已是最新版本')),
      );
      return;
    }

    _showUpdateDialog(update);
  }

  void _showUpdateDialog(Map<String, dynamic> update) {
    final version = update['latestVersion'] as String;
    final notes = update['releaseNotes'] as String;
    final url = update['downloadUrl'] as String;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('发现新版本 v$version'),
        content: SingleChildScrollView(child: Text(notes)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('去下载'),
          ),
        ],
      ),
    );
  }

  // ---- Cache Clearing Logic ----

  void _handleClearCache() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('将清除 WebView 缓存，登录状态不受影响'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _channel.invokeMethod('clearWebCache');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('缓存已清除')),
                  );
                }
              } on PlatformException catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('清除失败，请稍后重试')),
                  );
                }
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}

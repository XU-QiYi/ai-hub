import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme_config.dart';
import '../config/services_config.dart';
import '../models/ai_service.dart';
import '../services/storage_service.dart';
import '../widgets/service_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _channel = MethodChannel('com.aihub.webview');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, int> _clickCounts = {};
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadClickCounts();
  }

  Future<void> _loadClickCounts() async {
    final counts = await _storageService.getAllClickCounts();
    setState(() {
      _clickCounts = counts;
    });
  }

  List<AiService> get _sortedServices {
    final services = List<AiService>.from(aiServices);
    services.sort((a, b) {
      final aCount = _clickCounts[a.name] ?? 0;
      final bCount = _clickCounts[b.name] ?? 0;
      if (aCount > 0 && bCount > 0) return bCount.compareTo(aCount);
      if (aCount > 0) return -1;
      if (bCount > 0) return 1;
      return 0;
    });
    return services;
  }

  List<AiService> get _filteredServices {
    final sorted = _sortedServices;
    if (_searchQuery.isEmpty) return sorted;
    final query = _searchQuery.toLowerCase();
    return sorted.where((s) {
      return s.name.toLowerCase().contains(query) ||
          s.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final secondaryColor = AppColors.secondaryText(isDark: isDark);
    final searchBg = AppColors.searchBackground(isDark: isDark);
    final searchBorderColor = AppColors.searchBorder(isDark: isDark);
    final filtered = _filteredServices;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Hub',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: '搜索 AI 服务...',
                hintStyle: TextStyle(color: secondaryColor),
                prefixIcon: Icon(Icons.search_outlined, color: secondaryColor),
                filled: true,
                fillColor: searchBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: searchBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: searchBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: searchBorderColor, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      '没有找到匹配的服务',
                      style: TextStyle(color: secondaryColor, fontSize: 14),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final service = filtered[index];
                      return ServiceCard(
                        service: service,
                        onTap: () async {
                          await _storageService.incrementClick(service.name);
                          final newCounts =
                              await _storageService.getAllClickCounts();
                          setState(() {
                            _clickCounts = newCounts;
                          });
                          try {
                            if (service.packageName != null) {
                              final installed = await _channel.invokeMethod(
                                  'checkAppInstalled',
                                  {'packageName': service.packageName});
                              debugPrint(
                                  '[AiHub] ${service.name} packageName=${service.packageName} installed=$installed');
                              if (installed == true) {
                                try {
                                  await _channel.invokeMethod('launchApp',
                                      {'packageName': service.packageName});
                                  return;
                                } on PlatformException catch (e) {
                                  debugPrint('[AiHub] launchApp failed: ${e.message}');
                                }
                              }
                            }
                            await _channel.invokeMethod(
                                'openUrl', {'url': service.url});
                          } on PlatformException catch (e) {
                            debugPrint('MethodChannel failed: ${e.message}');
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const _channel = MethodChannel('com.aihub.webview');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, int> _clickCounts = {};
  int _selectedTab = 0; // 0=全部, 1=国内, 2=国外

  StorageService get _storageService =>
      Provider.of<StorageService>(context, listen: false);

  late AnimationController _cardAnimController;

  @override
  void initState() {
    super.initState();
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardAnimController.forward();
    _loadClickCounts();
  }

  Future<void> _loadClickCounts() async {
    final counts = await _storageService.getAllClickCounts();
    debugPrint('[AiHub] _clickCounts loaded: $counts');
    setState(() {
      _clickCounts = counts;
    });
  }

  List<AiService> get _sortedServices {
    // 按区域分组后分别排序，再合并
    final domestic = <AiService>[];
    final overseas = <AiService>[];
    for (final s in aiServices) {
      if (s.region == 'domestic') {
        domestic.add(s);
      } else {
        overseas.add(s);
      }
    }

    int compareByClick(List<AiService> list, AiService a, AiService b) {
      final aCount = _clickCounts[a.name] ?? 0;
      final bCount = _clickCounts[b.name] ?? 0;
      if (aCount > 0 && bCount > 0) return bCount.compareTo(aCount);
      if (aCount > 0) return -1;
      if (bCount > 0) return 1;
      return list.indexOf(a).compareTo(list.indexOf(b));
    }

    domestic.sort((a, b) => compareByClick(domestic, a, b));
    overseas.sort((a, b) => compareByClick(overseas, a, b));

    return [...domestic, ...overseas];
  }

  List<AiService> get _filteredServices {
    var result = _sortedServices;
    // Tab 筛选
    if (_selectedTab == 1) {
      result = result.where((s) => s.region == 'domestic').toList();
    } else if (_selectedTab == 2) {
      result = result.where((s) => s.region == 'overseas').toList();
    }
    // 搜索二次过滤
    if (_searchQuery.isEmpty) return result;
    final query = _searchQuery.toLowerCase();
    return result.where((s) {
      return s.name.toLowerCase().contains(query) ||
          s.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cardAnimController.dispose();
    super.dispose();
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final primaryColor = AppColors.primaryText(isDark: isDark);

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : primaryColor.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
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
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        elevation: 0,
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
          // ---- Tab 栏 ----
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTabButton('全部', 0),
                const SizedBox(width: 8),
                _buildTabButton('国内', 1),
                const SizedBox(width: 8),
                _buildTabButton('海外', 2),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: secondaryColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '没有找到匹配的服务',
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
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
                      childAspectRatio: 1.1,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final service = filtered[index];
                      final delay = (index * 60).clamp(0, 400);
                      final start = delay / 600.0;
                      final end = ((delay + 300) / 600.0).clamp(0.0, 1.0);
                      final interval =
                          Interval(start, end, curve: Curves.easeOut);

                      return AnimatedBuilder(
                        animation: _cardAnimController,
                        builder: (context, child) {
                          final value =
                              interval.transform(_cardAnimController.value);
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: ServiceCard(
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
                                    debugPrint(
                                        '[AiHub] launchApp failed: ${e.message}');
                                  }
                                }
                              }
                              await _channel.invokeMethod(
                                  'openUrl', {'url': service.url});
                            } on PlatformException catch (e) {
                              debugPrint('MethodChannel failed: ${e.message}');
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

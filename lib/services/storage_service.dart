import 'package:shared_preferences/shared_preferences.dart';
import '../utils/week_utils.dart';

/// Service for managing click count storage using SharedPreferences.
class StorageService {
  SharedPreferences? _prefs;

  /// Initialize SharedPreferences. Must be called before using other methods.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get the click count for a specific service in the current week.
  Future<int> getClickCount(String serviceName) async {
    final key = '${WeekUtils.getCurrentWeekKey()}_$serviceName';
    return _prefs?.getInt(key) ?? 0;
  }

  /// Increment the click count for a specific service.
  Future<void> incrementClick(String serviceName) async {
    final key = '${WeekUtils.getCurrentWeekKey()}_$serviceName';
    final currentCount = _prefs?.getInt(key) ?? 0;
    await _prefs?.setInt(key, currentCount + 1);
  }

  /// Get all click counts for the current week.
  Future<Map<String, int>> getAllClickCounts() async {
    final weekKey = WeekUtils.getCurrentWeekKey();
    final result = <String, int>{};

    if (_prefs != null) {
      for (final key in _prefs!.getKeys()) {
        if (key.startsWith('${weekKey}_')) {
          final serviceName = key.substring(weekKey.length + 1);
          result[serviceName] = _prefs!.getInt(key) ?? 0;
        }
      }
    }

    return result;
  }

  /// Clear all SharedPreferences data.
  Future<void> clearAllData() async {
    await _prefs?.clear();
  }
}

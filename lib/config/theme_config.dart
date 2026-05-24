import 'package:flutter/material.dart';

class AppColors {
  static Color background({required bool isDark}) {
    return isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
  }

  static Color cardBackground({required bool isDark}) {
    return isDark ? const Color(0xB31E1E28) : const Color(0xA6FFFFFF);
  }

  static Color cardPressed({required bool isDark}) {
    return isDark ? const Color(0xCC2A2A35) : const Color(0xFFE8E8E8);
  }

  static Color primaryText({required bool isDark}) {
    return isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);
  }

  static Color secondaryText({required bool isDark}) {
    return isDark ? const Color(0xFF888888) : const Color(0xFF666666);
  }

  static Color searchBackground({required bool isDark}) {
    return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF);
  }

  static Color searchBorder({required bool isDark}) {
    return isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0);
  }
}

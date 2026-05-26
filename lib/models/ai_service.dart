import 'package:flutter/material.dart';
import '../config/icons_config.dart';

class AiService {
  final String name;
  final String url;
  final String description;
  final IconData? icon;       // 保留，兼容旧的 Material Icon 方式
  final String? iconPath;     // SVG 图标路径
  final String? packageName;
  final String region;        // "domestic" 或 "overseas"
  final bool needVpn;         // 是否需要梯子
  final bool isCustom;        // 是否为用户自定义服务
  final String? iconName;     // 自定义图标的名称

  const AiService({
    required this.name,
    required this.url,
    required this.description,
    this.icon,
    this.iconPath,
    this.packageName,
    required this.region,
    this.needVpn = false,
    this.isCustom = false,
    this.iconName,
  });

  IconData? get resolvedIcon {
    if (icon != null) return icon;
    if (iconName != null) {
      return presetIconMap[iconName];
    }
    return null;
  }
}

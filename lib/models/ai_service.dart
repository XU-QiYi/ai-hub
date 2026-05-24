import 'package:flutter/material.dart';

class AiService {
  final String name;
  final String url;
  final String description;
  final IconData? icon;       // 保留，兼容旧的 Material Icon 方式
  final String? iconPath;     // SVG 图标路径
  final String? packageName;
  final String region;        // "domestic" 或 "overseas"
  final bool needVpn;         // 是否需要梯子

  const AiService({
    required this.name,
    required this.url,
    required this.description,
    this.icon,
    this.iconPath,
    this.packageName,
    required this.region,
    this.needVpn = false,
  });
}

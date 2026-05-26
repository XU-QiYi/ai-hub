import 'package:flutter/material.dart';

/// 预定义的自定义平台图标配置
/// 集中管理图标名称与图标的映射关系

/// 可用的预定义图标列表（用于 UI 显示）
const List<IconData> presetIcons = [
  Icons.smart_toy_outlined,      // 机器人
  Icons.chat_bubble_outline,     // 对话
  Icons.auto_awesome_outlined,   // 星形
  Icons.psychology_outlined,     // 大脑
  Icons.explore_outlined,        // 探索
  Icons.lightbulb_outlined,      // 灯泡
];

/// 图标名称到图标的映射（用于存储和读取）
final Map<String, IconData> presetIconMap = {
  'smart_toy_outlined': Icons.smart_toy_outlined,
  'chat_bubble_outline': Icons.chat_bubble_outline,
  'auto_awesome_outlined': Icons.auto_awesome_outlined,
  'psychology_outlined': Icons.psychology_outlined,
  'explore_outlined': Icons.explore_outlined,
  'lightbulb_outlined': Icons.lightbulb_outlined,
};

/// 图标到名称的映射（用于存储时转换）
final Map<IconData, String> presetIconNameMap = {
  Icons.smart_toy_outlined: 'smart_toy_outlined',
  Icons.chat_bubble_outline: 'chat_bubble_outline',
  Icons.auto_awesome_outlined: 'auto_awesome_outlined',
  Icons.psychology_outlined: 'psychology_outlined',
  Icons.explore_outlined: 'explore_outlined',
  Icons.lightbulb_outlined: 'lightbulb_outlined',
};

/// 根据图标获取名称
String getIconName(IconData icon) {
  return presetIconNameMap[icon] ?? 'smart_toy_outlined';
}

/// 根据名称获取图标
IconData? getIconByName(String name) {
  return presetIconMap[name];
}

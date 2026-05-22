import 'package:flutter/material.dart';

class AiService {
  final String name;
  final String url;
  final String description;
  final IconData icon;
  final String? packageName;

  const AiService({
    required this.name,
    required this.url,
    required this.description,
    required this.icon,
    this.packageName,
  });
}

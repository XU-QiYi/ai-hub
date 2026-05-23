import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/theme_config.dart';
import '../models/ai_service.dart';

class ServiceCard extends StatelessWidget {
  final AiService service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  Widget _buildIcon(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (ext == 'svg') {
      return SvgPicture.asset(path, width: 40, height: 40);
    }
    return Image.asset(path, width: 40, height: 40, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final primaryColor = AppColors.primaryText(isDark: isDark);
    final secondaryColor = AppColors.secondaryText(isDark: isDark);
    final bgColor = AppColors.cardBackground(isDark: isDark);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: primaryColor.withValues(alpha: 0.1),
          onTap: onTap,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIcon(service.iconPath),
                  const SizedBox(height: 8),
                  Text(
                    service.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String? base64Photo;
  final String username;
  final bool isOnline;
  final double size;
  final bool showOnlineIndicator;

  const UserAvatar({
    super.key,
    this.base64Photo,
    required this.username,
    this.isOnline = false,
    this.size = 48,
    this.showOnlineIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = base64Photo != null && base64Photo!.isNotEmpty;
    final indicatorSize = size * 0.28;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
            backgroundImage: hasPhoto ? MemoryImage(base64Decode(base64Photo!)) : null,
            child: hasPhoto
                ? null
                : Text(
                    username.isEmpty ? '?' : username[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
          ),
          if (showOnlineIndicator)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: indicatorSize,
                height: indicatorSize,
                decoration: BoxDecoration(
                  color: isOnline ? AppTheme.correctGreen : Colors.grey.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

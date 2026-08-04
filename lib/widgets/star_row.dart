import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class StarRow extends StatelessWidget {
  final int stars;
  final double size;

  const StarRow({super.key, required this.stars, this.size = 22});

  @override
  Widget build(BuildContext context) {
    final color = _starColor(stars);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final filled = index < stars;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: size,
          color: filled ? color : Colors.grey.shade400,
        );
      }),
    );
  }

  static Color _starColor(int stars) {
    switch (stars) {
      case 3:
        return AppTheme.starGold;
      case 2:
        return AppTheme.starSilver;
      case 1:
        return AppTheme.starBronze;
      default:
        return Colors.grey;
    }
  }
}

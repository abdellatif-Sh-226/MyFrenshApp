import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AnswerButton extends StatelessWidget {
  final String text;
  final int index;
  final bool? isCorrect;
  final bool isSelected;
  final bool isAnswered;
  final VoidCallback onTap;

  const AnswerButton({
    super.key,
    required this.text,
    required this.index,
    required this.isCorrect,
    required this.isSelected,
    required this.isAnswered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color? borderColor;
    IconData? icon;

    if (isAnswered && isSelected) {
      if (isCorrect == true) {
        bgColor = AppTheme.correctGreen;
        borderColor = AppTheme.correctGreen;
        icon = Icons.check_circle;
      } else {
        bgColor = AppTheme.wrongRed;
        borderColor = AppTheme.wrongRed;
        icon = Icons.cancel;
      }
    } else if (isAnswered && isCorrect == true) {
      bgColor = AppTheme.correctGreen.withValues(alpha: 0.15);
      borderColor = AppTheme.correctGreen;
      icon = Icons.check_circle;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isAnswered ? null : onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: bgColor ?? (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2C2C2C)
                    : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor ?? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white24
                      : Colors.grey.shade300),
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: !isAnswered
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isAnswered && isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: isAnswered && (isSelected || isCorrect == true)
                          ? Icon(icon, color: Colors.white, size: 20)
                          : Text(
                              String.fromCharCode(65 + index),
                              style: TextStyle(
                                color: isAnswered ? Colors.white54 : AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isAnswered && isSelected
                            ? Colors.white
                            : (isAnswered && isCorrect == true
                                ? AppTheme.correctGreen
                                : (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87)),
                        decoration: isAnswered && isSelected && isCorrect == false
                            ? TextDecoration.lineThrough
                            : null,
                      ),
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

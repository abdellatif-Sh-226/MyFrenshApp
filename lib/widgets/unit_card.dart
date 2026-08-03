import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/unit_model.dart';

class UnitCard extends StatelessWidget {
  final Unit unit;
  final VoidCallback onTap;
  final VoidCallback? onStudy;
  final VoidCallback? onWrite;
  final bool writeLocked;

  const UnitCard({
    super.key,
    required this.unit,
    required this.onTap,
    this.onStudy,
    this.onWrite,
    this.writeLocked = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = unit.completed;
    final isLocked = unit.locked;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: isLocked ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Card(
            elevation: isCompleted ? 6 : 4,
            shadowColor: isCompleted
                ? AppTheme.correctGreen.withValues(alpha: 0.3)
                : Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: isCompleted
                  ? BorderSide(color: AppTheme.correctGreen.withValues(alpha: 0.5), width: 1.5)
                  : BorderSide.none,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isLocked ? null : onTap,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _buildUnitNumber(context, isLocked),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLocked ? 'Locked Unit ${unit.unitNumber}' : 'Unit ${unit.unitNumber}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isLocked ? Colors.grey : null,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isLocked
                                  ? Colors.grey.withValues(alpha: 0.15)
                                  : _difficultyColor(unit.difficulty).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isLocked ? 'Locked' : unit.difficulty,
                              style: TextStyle(
                                color: isLocked ? Colors.grey : _difficultyColor(unit.difficulty),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (isLocked)
                            Text(
                              'Unlock by scoring ${AppConstants.passThreshold} in unit ${unit.unitNumber - 1}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white38 : Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                            )
                          else if (unit.bestScore > 0)
                            Row(
                              children: [
                                Icon(Icons.star, size: 16, color: AppTheme.accentColor),
                                const SizedBox(width: 4),
                                Text(
                                  'Best: ${unit.bestScore} / ${unit.totalQuestions}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            )
                          else
                            Text(
                              'Not Attempted',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white38 : Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    if (!isLocked && (onStudy != null || onWrite != null || isCompleted))
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isLocked && onStudy != null)
                            Tooltip(
                              message: 'Study lesson',
                              child: IconButton(
                                icon: Icon(
                                  Icons.school_outlined,
                                  color: AppTheme.primaryColor,
                                ),
                                onPressed: onStudy,
                              ),
                            ),
                          if (!isLocked && onWrite != null)
                            Tooltip(
                              message: writeLocked
                                  ? 'Score ${AppConstants.questionsPerUnit}/${AppConstants.questionsPerUnit} to unlock the writing test'
                                  : 'Writing test',
                              child: IconButton(
                                icon: Icon(
                                  writeLocked
                                      ? Icons.edit_off
                                      : Icons.edit_note,
                                  color: writeLocked
                                      ? Colors.grey
                                      : AppTheme.accentColor,
                                ),
                                onPressed: onWrite,
                              ),
                            ),
                          if (isCompleted) _buildCompletionBadge(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitNumber(BuildContext context, [bool isLocked = false]) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLocked
              ? [Colors.grey.shade600, Colors.grey.shade500]
              : [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha: 0.7),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isLocked ? Colors.grey : AppTheme.primaryColor).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: isLocked
            ? const Icon(Icons.lock, color: Colors.white)
            : Text(
                '${unit.unitNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildCompletionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.correctGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.correctGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: AppTheme.correctGreen, size: 18),
          const SizedBox(width: 4),
          Text(
            'Completed',
            style: TextStyle(
              color: AppTheme.correctGreen,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Elementary':
        return Colors.blue;
      case 'Intermediate':
        return AppTheme.accentColor;
      case 'Upper Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.deepOrange;
      case 'Expert':
        return AppTheme.wrongRed;
      default:
        return Colors.grey;
    }
  }
}

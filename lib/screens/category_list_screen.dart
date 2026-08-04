import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/unit_model.dart';
import '../providers/content_provider.dart';
import '../providers/progress_provider.dart';
import 'lesson_list_screen.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final byCategory = content.unitsByCategory;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Category')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Pick a category to start learning',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white60
                      : Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 16),
          for (final category in UnitCategory.values)
            _buildCategoryCard(context, category, byCategory[category] ?? const []),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    UnitCategory category,
    List<Unit> units,
  ) {
    final progress = context.read<ProgressProvider>();
    var completedCount = 0;
    var unlockedCount = 0;
    for (final unit in units) {
      progress.applyScoreToUnit(unit, context.read<ContentProvider>().units);
      if (unit.completed) completedCount++;
      if (!unit.locked) unlockedCount++;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _categoryColor(category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LessonListScreen(category: category),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(category.icon, color: accent, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount/${units.length} completed · '
                      '$unlockedCount unlocked',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(UnitCategory category) {
    switch (category) {
      case UnitCategory.noms:
        return Colors.blue;
      case UnitCategory.verbes:
        return AppTheme.correctGreen;
      case UnitCategory.phrases:
        return AppTheme.accentColor;
    }
  }
}

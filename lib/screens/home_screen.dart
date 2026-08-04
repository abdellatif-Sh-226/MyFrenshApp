import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/unit_model.dart';
import '../providers/content_provider.dart';
import '../providers/progress_provider.dart';
import 'alphabet_screen.dart';
import 'category_list_screen.dart';
import 'courses_screen.dart';
import 'story_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contentProvider = context.read<ContentProvider>();
      if (!contentProvider.loaded) {
        contentProvider.loadAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'French Vocabulary Master',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_outlined),
            tooltip: 'Friends',
            onPressed: () => Navigator.pushNamed(context, '/friends'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ContentProvider>().loadAll(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Welcome!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'What would you like to do today?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 16),
            _buildLessonsSummary(context),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _DashboardCard(
                  icon: Icons.menu_book_outlined,
                  label: 'Lessons',
                  subtitle: 'Noms · Verbes · Phrases',
                  color: AppTheme.primaryColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CategoryListScreen(),
                    ),
                  ),
                ),
                _DashboardCard(
                  icon: Icons.school_outlined,
                  label: 'Courses',
                  subtitle: 'Grammar lessons',
                  color: AppTheme.accentColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CoursesScreen(),
                    ),
                  ),
                ),
                _DashboardCard(
                  icon: Icons.auto_stories_outlined,
                  label: 'Stories',
                  subtitle: 'Read in French',
                  color: AppTheme.correctGreen,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StoryListView(),
                    ),
                  ),
                ),
                _DashboardCard(
                  icon: Icons.abc_outlined,
                  label: 'Alphabet',
                  subtitle: 'Letters & sounds',
                  color: Colors.deepPurple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AlphabetGridView(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsSummary(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final progress = context.watch<ProgressProvider>();
    final byCategory = content.unitsByCategory;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            for (final category in UnitCategory.values)
              _buildCategoryProgress(
                context,
                category,
                byCategory[category] ?? const [],
                progress,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgress(
    BuildContext context,
    UnitCategory category,
    List<Unit> units,
    ProgressProvider progress,
  ) {
    var completed = 0;
    for (final unit in units) {
      final copy = _copyUnit(unit);
      progress.applyScoreToUnit(copy, context.read<ContentProvider>().units);
      if (copy.completed) completed++;
    }

    final color = _categoryColor(category);
    final percent = units.isEmpty ? 0.0 : completed / units.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(category.icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '$completed/${units.length}',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white60
                            : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white12
                        : Colors.grey.shade200,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Unit _copyUnit(Unit unit) {
    return Unit(
      unitNumber: unit.unitNumber,
      title: unit.title,
      category: unit.category,
      difficulty: unit.difficulty,
      order: unit.order,
      prerequisites: unit.prerequisites,
      questions: unit.questions,
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

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

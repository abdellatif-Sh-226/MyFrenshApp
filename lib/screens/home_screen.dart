import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/unit_model.dart';
import '../providers/progress_provider.dart';
import '../services/json_loader_service.dart';
import '../widgets/unit_card.dart';
import 'alphabet_screen.dart';
import 'courses_screen.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';
import 'spelling_screen.dart';
import 'story_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Unit> _units = [];
  bool _loading = true;
  int _currentTab = 0;

  static const List<String> _tabTitles = [
    'Units',
    'Courses',
    'Stories',
    'Alphabet',
  ];

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    final progressProvider = context.read<ProgressProvider>();
    final jsonLoader = JsonLoaderService();

    final List<Unit> units = [];
    for (int i = 1; i <= AppConstants.totalUnits; i++) {
      final questions = await jsonLoader.loadUnitQuestions(i);
      final unit = Unit(
        unitNumber: i,
        difficulty: AppConstants.unitDifficulties[i - 1],
        questions: questions,
      );
      progressProvider.applyScoreToUnit(unit);
      units.add(unit);
    }

    if (mounted) {
      setState(() {
        _units = units;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tabTitles[_currentTab],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<ProgressProvider>(
            builder: (context, progress, child) {
              final count = progress.mistakes.length;
              return IconButton(
                tooltip: 'My Mistakes',
                onPressed: () => Navigator.pushNamed(context, '/mistakes'),
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.error_outline),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildUnitsTab(context, isDark),
          const CoursesScreen(),
          const StoryListView(),
          const AlphabetGridView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (index) => setState(() => _currentTab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Units',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Stories',
          ),
          NavigationDestination(
            icon: Icon(Icons.abc_outlined),
            selectedIcon: Icon(Icons.abc),
            label: 'Alphabet',
          ),
        ],
      ),
    );
  }

  Widget _buildUnitsTab(BuildContext context, bool isDark) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadUnits,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isDark),
          Expanded(
            child: Consumer<ProgressProvider>(
              builder: (context, progressProvider, child) {
                final displayUnits = _units.map((unit) {
                  final copy = Unit(
                    unitNumber: unit.unitNumber,
                    difficulty: unit.difficulty,
                    questions: unit.questions,
                  );
                  progressProvider.applyScoreToUnit(copy);
                  return copy;
                }).toList();
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: displayUnits.length,
                  itemBuilder: (context, index) {
                    final unit = displayUnits[index];
                    return UnitCard(
                      unit: unit,
                      onTap: () => _startQuiz(unit),
                      onStudy: () => _openLesson(unit),
                      onWrite: () => _openWritingPractice(unit),
                      writeLocked: false,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a Unit',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${_units.length} units · ${AppConstants.questionsPerUnit} questions each',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }

  void _startQuiz(Unit unit) {
    final progressProvider = context.read<ProgressProvider>();
    if (unit.locked && !progressProvider.canOpenUnit(unit.unitNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You need to score ${AppConstants.passThreshold} in unit ${unit.unitNumber - 1} to unlock this unit.',
          ),
        ),
      );
      return;
    }

    if (unit.bestScore >= AppConstants.writingTestUnlockScore) {
      _showUnitChoice(unit);
      return;
    }

    _pushQuiz(unit);
  }

  void _showUnitChoice(Unit unit) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Unit ${unit.unitNumber}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a test',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pushQuiz(unit);
                    },
                    icon: const Icon(Icons.quiz_outlined),
                    label: const Text('Normal Quiz'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openWritingTest(unit);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                    ),
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Writing Test (harder)'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pushQuiz(Unit unit) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuizScreen(unit: unit),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _openLesson(Unit unit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonScreen(unit: unit),
      ),
    );
  }

  void _openWritingPractice(Unit unit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpellingScreen(
          title: 'Unit ${unit.unitNumber} · Writing Practice',
          questions: unit.questions,
          mode: SpellingMode.practice,
          unitNumber: unit.unitNumber,
        ),
      ),
    );
  }

  void _openWritingTest(Unit unit) {
    if (unit.bestScore < AppConstants.writingTestUnlockScore) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Score ${AppConstants.writingTestUnlockScore}/${AppConstants.questionsPerUnit} in unit ${unit.unitNumber} to unlock the writing test.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpellingScreen(
          title: 'Unit ${unit.unitNumber} · Writing Test',
          questions: unit.questions,
          mode: SpellingMode.test,
          unitNumber: unit.unitNumber,
        ),
      ),
    );
  }
}

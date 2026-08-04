import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/unit_model.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/unit_card.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';
import 'spelling_screen.dart';

class LessonListScreen extends StatefulWidget {
  final UnitCategory category;

  const LessonListScreen({super.key, required this.category});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final progress = context.watch<ProgressProvider>();
    final units = content.unitsByCategory[widget.category] ?? const <Unit>[];

    final displayUnits = units.map((unit) {
      final copy = _copyUnit(unit);
      progress.applyScoreToUnit(copy, content.units);
      return copy;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.label)),
      body: RefreshIndicator(
        onRefresh: content.loadAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, displayUnits),
            Expanded(
              child: ListView.builder(
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
              ),
            ),
          ],
        ),
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

  Widget _buildHeader(BuildContext context, List<Unit> units) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    var completed = 0;
    for (final unit in units) {
      if (unit.completed) completed++;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.category.label,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '$completed/${units.length} completed · ${AppConstants.questionsPerUnit} questions each',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
          ),
          if (widget.category == UnitCategory.phrases) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppTheme.accentColor, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Phrase lessons use vocabulary from the Noms and Verbes '
                      'lessons. Each lesson shows which ones are recommended first.',
                      style: TextStyle(color: AppTheme.accentColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _startQuiz(Unit unit) {
    final progressProvider = context.read<ProgressProvider>();
    final isAdmin = context.read<AuthProvider>().isAdmin;

    if (unit.locked) {
      _showLockedMessage(unit);
      return;
    }

    if (unit.isPhrase && !isAdmin && !progressProvider.arePrerequisitesMet(unit)) {
      _showPrerequisiteDialog(unit, progressProvider);
      return;
    }

    if (isAdmin || unit.bestScore >= AppConstants.writingTestUnlockScore) {
      _showUnitChoice(unit);
      return;
    }

    _pushQuiz(unit);
  }

  void _showLockedMessage(Unit unit) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Score ${AppConstants.unlockScore}/${AppConstants.questionsPerUnit} '
          'in the previous ${unit.category.labelSingular} lesson to unlock this one.',
        ),
      ),
    );
  }

  void _showPrerequisiteDialog(Unit unit, ProgressProvider progress) {
    final content = context.read<ContentProvider>();
    showDialog(
      context: context,
      builder: (ctx) {
        final rows = <Widget>[];
        for (final prereqNumber in unit.prerequisites) {
          Unit? prereqUnit;
          for (final u in content.units) {
            if (u.unitNumber == prereqNumber) {
              prereqUnit = u;
              break;
            }
          }
          if (prereqUnit == null) continue;
          final done =
              progress.getBestScore(prereqNumber) >= AppConstants.unlockScore;
          rows.add(
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                done ? Icons.check_circle : Icons.cancel,
                color: done ? AppTheme.correctGreen : AppTheme.wrongRed,
              ),
              title: Text(
                '${prereqUnit.title} (${prereqUnit.category.labelSingular})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Text(
                done ? 'Done' : 'Not yet',
                style: TextStyle(
                  color: done ? AppTheme.correctGreen : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Prerequisite Recommended'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This phrase lesson uses vocabulary from:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...rows,
              const SizedBox(height: 8),
              const Text(
                'You can try it now, but studying those lessons first will help.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Study First'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _continueToQuiz(unit);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
              ),
              icon: const Icon(Icons.bolt),
              label: const Text('Try Anyway'),
            ),
          ],
        );
      },
    );
  }

  void _continueToQuiz(Unit unit) {
    final isAdmin = context.read<AuthProvider>().isAdmin;
    if (isAdmin || unit.bestScore >= AppConstants.writingTestUnlockScore) {
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
                  unit.displayTitle,
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
    final isAdmin = context.read<AuthProvider>().isAdmin;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuizScreen(unit: unit, adminMode: isAdmin),
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
          title: '${unit.displayTitle} · Writing Practice',
          questions: unit.questions,
          mode: SpellingMode.practice,
          unitNumber: unit.unitNumber,
        ),
      ),
    );
  }

  void _openWritingTest(Unit unit) {
    final isAdmin = context.read<AuthProvider>().isAdmin;
    if (!isAdmin && unit.bestScore < AppConstants.writingTestUnlockScore) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Score ${AppConstants.writingTestUnlockScore}/${AppConstants.questionsPerUnit} '
            'in ${unit.displayTitle} to unlock the writing test.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpellingScreen(
          title: '${unit.displayTitle} · Writing Test',
          questions: unit.questions,
          mode: SpellingMode.test,
          unitNumber: unit.unitNumber,
        ),
      ),
    );
  }
}

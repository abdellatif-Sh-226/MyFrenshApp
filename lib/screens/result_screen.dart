import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/quiz_result_model.dart';
import '../models/unit_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/result_animation.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  final QuizResult result;
  final Unit? unit;

  const ResultScreen({super.key, required this.result, this.unit});

  int get pointsEarned {
    final u = unit;
    if (u == null) return 0;
    return AppConstants.pointsForUnit(u.category.name, result.score);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                ResultAnimation(
                  stars: Unit.starsForScore(result.score),
                  performance: result.performance,
                ),
                const SizedBox(height: 32),
                _buildScoreCard(context),
                const SizedBox(height: 32),
                _buildStatsRow(context),
                const SizedBox(height: 24),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        child: Column(
          children: [
            Text(
              'Congratulations!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              '${result.score} / ${result.totalQuestions}',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(result.percentage * 100).toInt()}%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            if (result.isPerfect) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: AppTheme.accentColor, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Perfect Score!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: _buildStatItem(
          context,
          icon: Icons.check_circle,
          label: 'Correct',
          value: '${result.score}',
          color: AppTheme.correctGreen,
        )),
        Expanded(child: _buildStatItem(
          context,
          icon: Icons.cancel,
          label: 'Wrong',
          value: '${result.totalQuestions - result.score}',
          color: AppTheme.wrongRed,
        )),
        Expanded(child: _buildStatItem(
          context,
          icon: Icons.quiz_outlined,
          label: 'Total',
          value: '${result.totalQuestions}',
          color: AppTheme.primaryColor,
        )),
        Expanded(child: _buildStatItem(
          context,
          icon: Icons.stars,
          label: 'Points',
          value: '$pointsEarned',
          color: AppTheme.accentColor,
        )),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _goHome(context),
            icon: const Icon(Icons.home),
            label: const Text('Back to Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _replayQuiz(context),
            icon: const Icon(Icons.replay),
            label: const Text('Replay Unit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _goHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _replayQuiz(BuildContext context) {
    final unit = this.unit;
    if (unit == null) {
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => QuizScreen(
          unit: unit,
          adminMode: context.read<AuthProvider>().isAdmin,
        ),
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
}

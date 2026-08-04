import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/progress_provider.dart';

class MistakesScreen extends StatefulWidget {
  const MistakesScreen({super.key});

  @override
  State<MistakesScreen> createState() => _MistakesScreenState();
}

class _MistakesScreenState extends State<MistakesScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(0.7);
    await _flutterTts.setPitch(1.0);
  }

  void _speak(String word) {
    _flutterTts.stop();
    _flutterTts.speak(word);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mistakes = context.watch<ProgressProvider>().mistakes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Mistakes'),
        actions: [
          if (mistakes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear mistakes',
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: mistakes.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mistakes.length,
              itemBuilder: (context, index) {
                final mistake = mistakes[index];
                return _MistakeCard(
                  word: mistake.word,
                  meaning: mistake.meaning,
                  wrong: mistake.wrongAnswer,
                  unitNumber: mistake.unitNumber,
                  onSpeak: () => _speak(mistake.word),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.correctGreen,
            ),
            const SizedBox(height: 16),
            Text(
              'No mistakes yet!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Every wrong answer in a unit quiz is saved here so you can review it.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear mistakes?'),
        content: const Text('All saved mistakes will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProgressProvider>().clearMistakes();
              Navigator.pop(ctx);
            },
            child: const Text('Clear', style: TextStyle(color: AppTheme.wrongRed)),
          ),
        ],
      ),
    );
  }
}

class _MistakeCard extends StatelessWidget {
  final String word;
  final String meaning;
  final String wrong;
  final int unitNumber;
  final VoidCallback onSpeak;

  const _MistakeCard({
    required this.word,
    required this.meaning,
    required this.wrong,
    required this.unitNumber,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    word,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: AppTheme.primaryColor),
                  onPressed: onSpeak,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 18, color: AppTheme.correctGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    meaning,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.correctGreen,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.cancel, size: 18, color: AppTheme.wrongRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    wrong,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.wrongRed,
                          decoration: TextDecoration.lineThrough,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Unit $unitNumber',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

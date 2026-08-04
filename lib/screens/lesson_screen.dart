import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/theme/app_theme.dart';
import '../models/unit_model.dart';
import 'spelling_screen.dart';

class LessonScreen extends StatefulWidget {
  final Unit unit;

  const LessonScreen({super.key, required this.unit});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
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

  void _openPractice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpellingScreen(
          title: '${widget.unit.displayTitle} · Writing Practice',
          questions: widget.unit.questions,
          mode: SpellingMode.practice,
          unitNumber: widget.unit.unitNumber,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unit.displayTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.unit.questions.length} words to study',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white60
                              : Colors.grey.shade600,
                        ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _openPractice,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Practice writing'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: widget.unit.questions.length,
              itemBuilder: (context, index) {
                final question = widget.unit.questions[index];
                return _WordLessonCard(
                  word: question.word,
                  arabic: question.arabicTranslation,
                  meaning: question.meaning,
                  example: question.example,
                  onSpeak: () => _speak(question.word),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WordLessonCard extends StatelessWidget {
  final String word;
  final String arabic;
  final String meaning;
  final String example;
  final VoidCallback onSpeak;

  const _WordLessonCard({
    required this.word,
    required this.arabic,
    required this.meaning,
    required this.example,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                InkWell(
                  onTap: onSpeak,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Translation: $arabic',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
            _infoRow(context, Icons.translate, 'Usage', meaning),
            const SizedBox(height: 8),
            _infoRow(context, Icons.format_quote, 'Example', example),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

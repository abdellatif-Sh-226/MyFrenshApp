import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/theme/app_theme.dart';
import '../models/question_model.dart';

enum SpellingMode { practice, test }

enum _SpellingStatus { idle, correct, wrong, revealed }

class SpellingScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final SpellingMode mode;

  const SpellingScreen({
    super.key,
    required this.title,
    required this.questions,
    required this.mode,
  });

  @override
  State<SpellingScreen> createState() => _SpellingScreenState();
}

class _SpellingScreenState extends State<SpellingScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _controller = TextEditingController();

  int _index = 0;
  int _score = 0;
  _SpellingStatus _status = _SpellingStatus.idle;
  bool _finished = false;

  Question get question => widget.questions[_index];

  @override
  void initState() {
    super.initState();
    _configureTts();
    _speak();
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _speak() {
    _flutterTts.stop();
    _flutterTts.speak(question.word);
  }

  @override
  void dispose() {
    _controller.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  void _check() {
    if (_status == _SpellingStatus.correct || _status == _SpellingStatus.revealed) {
      _next();
      return;
    }
    if (_controller.text.trim().isEmpty) return;

    final correct = _normalize(_controller.text) == _normalize(question.word);
    setState(() {
      if (correct) {
        _status = _SpellingStatus.correct;
        if (widget.mode == SpellingMode.test) _score++;
      } else {
        _status = _SpellingStatus.wrong;
      }
    });
  }

  void _reveal() {
    setState(() {
      _status = _SpellingStatus.revealed;
    });
  }

  void _next() {
    if (_index >= widget.questions.length - 1) {
      setState(() {
        _finished = true;
      });
      return;
    }
    setState(() {
      _index++;
      _status = _SpellingStatus.idle;
      _controller.clear();
    });
    _speak();
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _status = _SpellingStatus.idle;
      _finished = false;
      _controller.clear();
    });
    _speak();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _buildResult(context);
    }

    final isPractice = widget.mode == SpellingMode.practice;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Word ${_index + 1} / ${widget.questions.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (!isPractice)
                    Text(
                      'Score: $_score',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_index + 1) / widget.questions.length,
                  minHeight: 8,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white12
                          : Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      isPractice
                          ? 'Write the word in French'
                          : 'Write the French word',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.answer,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.volume_up),
                      tooltip: 'Hear the word',
                      onPressed: _speak,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _controller,
                enabled: _status != _SpellingStatus.correct,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22),
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'Type the French word…',
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2C2C2C)
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _check(),
              ),
            ),
            const SizedBox(height: 16),
            if (_status == _SpellingStatus.correct)
              _feedbackChip(context, AppTheme.correctGreen, Icons.check_circle,
                  'Correct !')
            else if (_status == _SpellingStatus.wrong)
              _feedbackChip(
                  context,
                  AppTheme.wrongRed,
                  Icons.cancel,
                  'Incorrect. Correct answer: ${question.word}')
            else if (_status == _SpellingStatus.revealed)
              _feedbackChip(context, AppTheme.accentColor, Icons.lightbulb,
                  'Answer: ${question.word}'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  if (isPractice &&
                      _status != _SpellingStatus.correct &&
                      _status != _SpellingStatus.revealed) ...[
                    OutlinedButton(
                      onPressed: _reveal,
                      child: const Text('Show answer'),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _check,
                        child: Text(
                          _status == _SpellingStatus.correct ||
                                  _status == _SpellingStatus.revealed
                              ? (_index >= widget.questions.length - 1
                                  ? 'Finish'
                                  : 'Next')
                              : 'Check',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedbackChip(BuildContext context, Color color, IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final percentage =
        widget.questions.isEmpty ? 0 : (_score / widget.questions.length) * 100;
    final passed = percentage >= 0.5;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.mode == SpellingMode.practice
                    ? Icons.emoji_events
                    : (passed ? Icons.emoji_events : Icons.replay_circle_filled_outlined),
                size: 72,
                color: widget.mode == SpellingMode.practice || passed
                    ? AppTheme.accentColor
                    : AppTheme.wrongRed,
              ),
              const SizedBox(height: 16),
              Text(
                widget.mode == SpellingMode.practice
                    ? 'Practice complete!'
                    : 'Writing Test Result',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (widget.mode == SpellingMode.test) ...[
                const SizedBox(height: 12),
                Text(
                  '$_score / ${widget.questions.length}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${percentage.round()}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  passed
                      ? 'Great spelling! Keep it up.'
                      : 'Practice more and try again.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.replay),
                  label: const Text('Practice again'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

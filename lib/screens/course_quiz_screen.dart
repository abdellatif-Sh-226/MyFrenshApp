import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/course_model.dart';
import '../providers/quiz_provider.dart';
import '../widgets/answer_button.dart';
import '../widgets/progress_bar_widget.dart';
import '../widgets/question_card.dart';

class CourseQuizScreen extends StatefulWidget {
  final Course course;

  const CourseQuizScreen({super.key, required this.course});

  @override
  State<CourseQuizScreen> createState() => _CourseQuizScreenState();
}

class _CourseQuizScreenState extends State<CourseQuizScreen> {
  late final FlutterTts _flutterTts;
  Timer? _answerTimer;
  int _lastSpokenIndex = -1;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _configureTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<QuizProvider>()
          .loadCustomQuestions(widget.course.lessons.length, widget.course.questions);
    });
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(0.7);
    await _flutterTts.setPitch(1.0);
  }

  void _maybeSpeakCurrentWord(QuizProvider quiz) {
    if (quiz.questions.isEmpty || quiz.currentIndex >= quiz.questions.length) {
      return;
    }
    if (quiz.currentIndex == _lastSpokenIndex) return;
    _lastSpokenIndex = quiz.currentIndex;
    final currentWord = quiz.currentQuestion.word;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _flutterTts.stop();
      await _flutterTts.speak(currentWord);
    });
  }

  Future<void> _speakWord(String word) async {
    await _flutterTts.stop();
    await _flutterTts.speak(word);
  }

  @override
  void dispose() {
    _answerTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  void _onAnswer(QuizProvider quiz, int index) {
    if (quiz.isAnswered) return;

    quiz.selectAnswer(index);
    _answerTimer?.cancel();
    _answerTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      if (quiz.isLastQuestion) {
        setState(() => _finished = true);
      } else {
        quiz.nextQuestion();
      }
    });
  }

  void _restart() {
    setState(() {
      _finished = false;
      _lastSpokenIndex = -1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<QuizProvider>()
          .loadCustomQuestions(widget.course.lessons.length, widget.course.questions);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _buildResult(context);
    }

    return Consumer<QuizProvider>(
      builder: (context, quiz, child) {
        if (quiz.isLoading || quiz.questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.course.title)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        _maybeSpeakCurrentWord(quiz);

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.course.title),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                ProgressBarWidget(
                  progress: quiz.progress,
                  current: quiz.currentIndex + 1,
                  total: quiz.totalQuestions,
                ),
                const SizedBox(height: 16),
                QuestionCard(
                  questionNumber:
                      'Question ${quiz.currentIndex + 1} / ${quiz.totalQuestions}',
                  prompt:
                      'Que signifie « ${quiz.currentQuestion.word} » ?',
                  word: quiz.currentQuestion.word,
                  onSpeak: () => _speakWord(quiz.currentQuestion.word),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: quiz.currentChoices.length,
                    itemBuilder: (context, index) {
                      final correct =
                          quiz.currentChoices[index] ==
                          quiz.currentQuestion.answer;
                      return AnswerButton(
                        text: quiz.currentChoices[index],
                        index: index,
                        isCorrect: correct,
                        isSelected: quiz.selectedAnswerIndex == index,
                        isAnswered: quiz.isAnswered,
                        onTap: () => _onAnswer(quiz, index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResult(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final total = quiz.totalQuestions;
    final score = quiz.score;
    final percentage = total == 0 ? 0 : (score / total) * 100;
    final passed = percentage >= 0.5;

    return Scaffold(
      appBar: AppBar(title: Text(widget.course.title)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                passed ? Icons.emoji_events : Icons.replay_circle_filled_outlined,
                size: 72,
                color: passed ? AppTheme.accentColor : AppTheme.wrongRed,
              ),
              const SizedBox(height: 16),
              Text(
                'Course Test Result',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                '$score / $total',
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
              const SizedBox(height: 16),
              Text(
                passed
                    ? 'Great job! You understood the questions.'
                    : 'Review the lessons and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.replay),
                  label: const Text('Retake Test'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Course'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

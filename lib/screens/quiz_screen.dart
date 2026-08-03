import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../models/mistake_model.dart';
import '../models/unit_model.dart';
import '../core/theme/app_theme.dart';
import '../providers/quiz_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/answer_button.dart';
import '../widgets/progress_bar_widget.dart';
import 'lesson_screen.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Unit unit;

  const QuizScreen({super.key, required this.unit});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final FlutterTts _flutterTts;
  Timer? _answerTimer;
  int _lastSpokenIndex = -1;
  int _promptIndex = 0;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _configureTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadUnit(widget.unit.unitNumber);
    });
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

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speakWord(String word) async {
    await _flutterTts.stop();
    await _flutterTts.speak(word);
  }

  String _promptFor(String word) {
    final prompts = [
      'Quelle est la traduction de « $word » ?',
      'Comment dit-on « $word » en arabe ?',
      'Que signifie « $word » ?',
      'Quel est le sens de « $word » ?',
    ];
    final prompt = prompts[_promptIndex % prompts.length];
    _promptIndex++;
    return prompt;
  }

  @override
  void dispose() {
    _answerTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quiz, child) {
        if (quiz.isLoading || quiz.questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text('Unit ${widget.unit.unitNumber}')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        _maybeSpeakCurrentWord(quiz);

        return Scaffold(
          appBar: AppBar(
            title: Text('Unit ${widget.unit.unitNumber}'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showExitDialog(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.school_outlined),
                tooltip: 'Word lesson',
                onPressed: () => _showLessonBottomSheet(quiz),
              ),
            ],
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        'Mistakes: ${quiz.answers.where((a) => !a).length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: quiz.answers.contains(false)
                                  ? AppTheme.wrongRed
                                  : Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white38
                                      : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                QuestionCard(
                  questionNumber:
                      'Question ${quiz.currentIndex + 1} / ${quiz.totalQuestions}',
                  prompt: _promptFor(quiz.currentQuestion.word),
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

  void _showLessonBottomSheet(QuizProvider quiz) {
    final question = quiz.currentQuestion;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      question.word,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: AppTheme.primaryColor),
                    tooltip: 'Listen',
                    onPressed: () => _speakWord(question.word),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Arabic translation: ${question.arabicTranslation}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                question.meaning,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Example: ${question.example}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(unit: widget.unit),
                      ),
                    );
                  },
                  icon: const Icon(Icons.school_outlined),
                  label: const Text('Study all unit words'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onAnswer(QuizProvider quiz, int index) {
    if (quiz.isAnswered) return;

    quiz.selectAnswer(index);
    _answerTimer?.cancel();
    _answerTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      if (quiz.isLastQuestion) {
        _finishQuiz(quiz);
      } else {
        quiz.nextQuestion();
      }
    });
  }

  Future<void> _finishQuiz(QuizProvider quiz) async {
    final result = quiz.getResult();
    final progressProvider = context.read<ProgressProvider>();
    await progressProvider.updateScore(quiz.unitNumber, result.score);

    final mistakes = <Mistake>[];
    for (int i = 0; i < quiz.questions.length; i++) {
      final question = quiz.questions[i];
      final selected = i < quiz.selectedValues.length
          ? quiz.selectedValues[i]
          : null;
      if (selected != null && selected != question.answer) {
        mistakes.add(
          Mistake(
            word: question.word,
            meaning: question.answer,
            wrongAnswer: selected,
            unitNumber: quiz.unitNumber,
            timestamp: DateTime.now(),
          ),
        );
      }
    }
    if (mistakes.isNotEmpty) {
      await progressProvider.recordMistakes(mistakes);
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ResultScreen(result: result, unit: widget.unit),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Leave Quiz?'),
        content: const Text('Your progress in this attempt will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

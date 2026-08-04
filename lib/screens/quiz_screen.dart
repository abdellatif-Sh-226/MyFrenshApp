import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../models/mistake_model.dart';
import '../models/question_model.dart';
import '../models/unit_model.dart';
import '../core/theme/app_theme.dart';
import '../providers/content_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/answer_button.dart';
import '../widgets/progress_bar_widget.dart';
import '../widgets/question_edit_dialog.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Unit unit;
  final bool adminMode;

  const QuizScreen({super.key, required this.unit, this.adminMode = false});

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
    await _flutterTts.setSpeechRate(0.7);
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
            appBar: AppBar(title: Text(widget.unit.displayTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        _maybeSpeakCurrentWord(quiz);

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.unit.displayTitle),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showExitDialog(context),
            ),
            actions: [
              if (widget.adminMode) ...[
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  tooltip: 'Previous question',
                  onPressed: quiz.currentIndex > 0
                      ? () => quiz.previousQuestion()
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  tooltip: 'Skip question',
                  onPressed: () => _adminSkip(quiz),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit answer',
                  onPressed: () => _adminEdit(quiz),
                ),
              ],
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
                  wordFontSize: widget.unit.isPhrase ? 22 : 32,
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

  void _adminSkip(QuizProvider quiz) {
    _answerTimer?.cancel();
    if (quiz.isLastQuestion) {
      _finishQuiz(quiz);
    } else {
      quiz.nextQuestion();
    }
  }

  Future<void> _adminEdit(QuizProvider quiz) async {
    final updated = await showDialog<Question>(
      context: context,
      builder: (_) => QuestionEditDialog(initial: quiz.currentQuestion),
    );
    if (updated == null || !mounted) return;

    try {
      final index = quiz.allQuestions.indexOf(quiz.currentQuestion);
      if (index >= 0) {
        final newList = List<Question>.from(quiz.allQuestions);
        newList[index] = updated;
        await context
            .read<ContentProvider>()
            .adminUpdateUnitQuestions(widget.unit.unitNumber, newList);
      }
      quiz.updateCurrentQuestion(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Answer saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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

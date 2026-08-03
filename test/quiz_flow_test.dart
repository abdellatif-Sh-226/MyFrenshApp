import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:french_vocabulary_master/models/question_model.dart';
import 'package:french_vocabulary_master/models/unit_model.dart';
import 'package:french_vocabulary_master/providers/quiz_provider.dart';
import 'package:french_vocabulary_master/providers/progress_provider.dart';
import 'package:french_vocabulary_master/screens/quiz_screen.dart';
import 'package:french_vocabulary_master/services/json_loader_service.dart';
import 'package:french_vocabulary_master/services/progress_service.dart';

class FakeJsonLoader implements JsonLoaderService {
  @override
  Future<List<Question>> loadUnitQuestions(int unitNumber) async {
    return List.generate(20, (i) {
      return Question(
        word: 'word$i',
        choices: ['correct$i', 'wrongA$i', 'wrongB$i', 'wrongC$i'],
        answer: 'correct$i',
        meaning: 'meaning of word$i',
        example: 'example with word$i',
        arabicTranslation: 'translation $i',
      );
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final messenger = TestDefaultBinaryMessengerBinding.instance
        .defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (call) async => null,
    );
  });

  testWidgets('quiz completes all 20 questions and shows the result screen',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});

    final progressService = ProgressService();
    await progressService.init();
    final progressProvider = ProgressProvider(progressService);
    await progressProvider.loadProgress();

    final quizProvider = QuizProvider(FakeJsonLoader());
    final questions = await FakeJsonLoader().loadUnitQuestions(1);
    final unit = Unit(
      unitNumber: 1,
      difficulty: 'Beginner',
      questions: questions,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: progressProvider),
          ChangeNotifierProvider.value(value: quizProvider),
        ],
        child: MaterialApp(home: QuizScreen(unit: unit)),
      ),
    );

    await tester.pumpAndSettle();

    for (int i = 0; i < 20; i++) {
      final answer = quizProvider.currentQuestion.answer;
      await tester.tap(find.text(answer), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 900));
    }

    await tester.pumpAndSettle();

    expect(find.text('Congratulations!'), findsOneWidget);
    expect(find.text('20 / 20'), findsOneWidget);
    expect(progressProvider.getBestScore(1), 20);
  });
}

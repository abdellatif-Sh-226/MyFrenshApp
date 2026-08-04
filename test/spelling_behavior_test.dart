import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:french_vocabulary_master/models/question_model.dart';
import 'package:french_vocabulary_master/providers/progress_provider.dart';
import 'package:french_vocabulary_master/screens/spelling_screen.dart';
import 'package:french_vocabulary_master/services/progress_service.dart';

Question _q(String word) {
  return Question(
    word: word,
    choices: const ['choice1', 'choice2', 'choice3', 'choice4'],
    answer: 'meaning of $word',
    meaning: 'usage of $word',
    example: 'example of $word',
    arabicTranslation: 'translation of $word',
  );
}

Future<void> _pumpSpelling(
  WidgetTester tester,
  SpellingMode mode, {
  required List<Question> questions,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final service = ProgressService();
  await service.init();
  final provider = ProgressProvider(service);
  await provider.loadProgress();

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        home: SpellingScreen(
          title: 'Writing',
          questions: questions,
          mode: mode,
          unitNumber: 1,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder get _field => find.byType(TextField);

Future<void> _typeAndCheck(WidgetTester tester, String text) async {
  await tester.enterText(_field, text);
  await tester.tap(find.text('Check'));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (call) async => null,
    );
  });

  testWidgets('test mode: a wrong attempt stays wrong even after correcting',
      (tester) async {
    await _pumpSpelling(tester, SpellingMode.test, questions: [_q('bonjour')]);

    await _typeAndCheck(tester, 'bonjro');
    expect(find.textContaining('Incorrect. Correct word: bonjour'),
        findsOneWidget);

    await _typeAndCheck(tester, 'bonjour');
    expect(find.textContaining('counts as wrong'), findsOneWidget);

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('0 / 1'), findsOneWidget);
  });

  testWidgets('test mode: a correct first attempt counts as correct',
      (tester) async {
    await _pumpSpelling(tester, SpellingMode.test, questions: [_q('bonjour')]);

    await _typeAndCheck(tester, 'bonjour');
    expect(find.text('Correct !'), findsOneWidget);
    expect(find.textContaining('counts as wrong'), findsNothing);

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('1 / 1'), findsOneWidget);
  });

  testWidgets('practice mode: needs N consecutive correct, wrong resets',
      (tester) async {
    await _pumpSpelling(tester, SpellingMode.practice,
        questions: [_q('bonjour')]);

    await _typeAndCheck(tester, 'bonjour');
    expect(find.text('Correct !'), findsOneWidget);
    expect(find.text('Attempt: 1/3'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);

    await _typeAndCheck(tester, 'bonjour');
    expect(find.text('Attempt: 2/3'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);

    await _typeAndCheck(tester, 'bonjro');
    expect(find.textContaining('Incorrect. Correct word: bonjour'),
        findsOneWidget);
    expect(find.text('Attempt: 0/3'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);

    await _typeAndCheck(tester, 'bonjour');
    await _typeAndCheck(tester, 'bonjour');
    await _typeAndCheck(tester, 'bonjour');
    expect(find.text('Attempt: 3/3'), findsOneWidget);
    expect(find.text('Finish'), findsOneWidget);

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Practice complete!'), findsOneWidget);
  });

  testWidgets('practice mode: repetitions adjustable between 2 and 10',
      (tester) async {
    await _pumpSpelling(tester, SpellingMode.practice,
        questions: [_q('bonjour')]);

    expect(find.text('3'), findsWidgets);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();
    expect(find.text('4'), findsWidgets);

    for (int i = 0; i < 10; i++) {
      await tester.tap(find.byIcon(Icons.remove_circle_outline));
      await tester.pump();
    }
    expect(find.text('2'), findsWidgets);

    for (int i = 0; i < 10; i++) {
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();
    }
    expect(find.text('10'), findsWidgets);
  });
}

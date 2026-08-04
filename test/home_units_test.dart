import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:french_vocabulary_master/providers/content_provider.dart';
import 'package:french_vocabulary_master/providers/progress_provider.dart';
import 'package:french_vocabulary_master/screens/home_screen.dart';
import 'package:french_vocabulary_master/services/api_service.dart';
import 'package:french_vocabulary_master/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home dashboard lists categories and lesson entry points', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final api = ApiService();
    await api.init();

    final progressService = ProgressService();
    await progressService.init();
    final progressProvider = ProgressProvider(progressService, api);
    await progressProvider.loadProgress();

    final contentProvider = ContentProvider(api);

    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: progressProvider),
          ChangeNotifierProvider.value(value: contentProvider),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lessons'), findsOneWidget);
    expect(find.text('Les Noms'), findsOneWidget);
    expect(find.text('Les Verbes'), findsOneWidget);
    expect(find.text('Les Phrases'), findsOneWidget);
  });
}

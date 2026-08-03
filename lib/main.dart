import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/quiz_provider.dart';
import 'services/json_loader_service.dart';
import 'services/progress_service.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/story_screen.dart';
import 'screens/alphabet_screen.dart';
import 'screens/mistakes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final progressService = ProgressService();
  await progressService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(progressService)..loadTheme(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProgressProvider(progressService)..loadProgress(),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(JsonLoaderService()),
        ),
      ],
      child: const FrenchVocabularyApp(),
    ),
  );
}

class FrenchVocabularyApp extends StatelessWidget {
  const FrenchVocabularyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'French Vocabulary Master',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/about': (context) => const AboutScreen(),
            '/stories': (context) => const StoryScreen(),
            '/alphabet': (context) => const AlphabetScreen(),
            '/mistakes': (context) => const MistakesScreen(),
          },
        );
      },
    );
  }
}

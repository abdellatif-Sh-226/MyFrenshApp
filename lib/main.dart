import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/content_provider.dart';
import 'providers/friends_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/quiz_provider.dart';
import 'services/api_service.dart';
import 'services/json_loader_service.dart';
import 'services/progress_service.dart';
import 'screens/friends_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/story_screen.dart';
import 'screens/alphabet_screen.dart';
import 'screens/mistakes_screen.dart';
import 'screens/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final api = ApiService();
  await api.init();

  final progressService = ProgressService();
  await progressService.init();

  final progressProvider = ProgressProvider(progressService, api);
  await progressProvider.loadProgress();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(progressService)..loadTheme(),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider(api)),
        ChangeNotifierProvider(create: (_) => progressProvider),
        ChangeNotifierProvider(
          create: (_) => ContentProvider(api),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(JsonLoaderService(api)),
        ),
        ChangeNotifierProvider(
          create: (_) => FriendsProvider(api),
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
          home: Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return auth.isLoggedIn ? const HomeScreen() : const LoginScreen();
            },
          ),
          routes: {
            '/settings': (context) => const SettingsScreen(),
            '/about': (context) => const AboutScreen(),
            '/stories': (context) => const StoryScreen(),
            '/alphabet': (context) => const AlphabetScreen(),
            '/mistakes': (context) => const MistakesScreen(),
            '/friends': (context) => const FriendsScreen(),
            '/admin': (context) => const AdminScreen(),
          },
        );
      },
    );
  }
}

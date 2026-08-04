import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'French Vocabulary Master';
  static const int totalUnits = 10;
  static const int questionsPerUnit = 20;
  static const int passThreshold = 18;
  static const int starOneMin = 16;
  static const int starTwoMin = 18;
  static const int starThreeMin = 20;
  static const int writingTestUnlockScore = 16;
  static const String assetsPath = 'assets/data';
  static const String prefsKeyPrefix = 'unit_score_';
  static const String writingScoreKeyPrefix = 'writing_score_';
  static const String prefsDarkModeKey = 'dark_mode';
  static const String prefsThemeKey = 'theme_mode';
  static const String mistakesKey = 'mistakes';

  static String unitFilePath(int unitNumber) => '$assetsPath/unit$unitNumber.json';

  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static const List<String> unitDifficulties = [
    'Beginner',
    'Beginner',
    'Elementary',
    'Elementary',
    'Intermediate',
    'Intermediate',
    'Upper Intermediate',
    'Advanced',
    'Advanced',
    'Expert',
  ];
}

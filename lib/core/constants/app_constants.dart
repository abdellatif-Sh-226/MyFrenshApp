class AppConstants {
  AppConstants._();

  static const String appName = 'French Vocabulary Master';
  static const int totalUnits = 10;
  static const int questionsPerUnit = 20;
  static const int passThreshold = 18;
  static const String assetsPath = 'assets/data';
  static const String prefsKeyPrefix = 'unit_score_';
  static const String prefsDarkModeKey = 'dark_mode';
  static const String prefsThemeKey = 'theme_mode';
  static const String mistakesKey = 'mistakes';

  static String unitFilePath(int unitNumber) => '$assetsPath/unit$unitNumber.json';

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

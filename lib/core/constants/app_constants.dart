class AppConstants {
  AppConstants._();

  static const String appName = 'French Vocabulary Master';
  static const int totalUnits = 15;
  static const int unitsPerCategory = 5;
  static const int questionsPerUnit = 20;
  static const int passThreshold = 18;
  static const int unlockScore = 16;
  static const int starOneMin = 16;
  static const int starTwoMin = 18;
  static const int starThreeMin = 20;
  static const int writingTestUnlockScore = 16;

  static const int nomsPointsPerCorrect = 10;
  static const int verbesPointsPerCorrect = 15;

  // Phrase scoring: score-based point brackets
  static const int phrasePointsLow = 40;      // 15-17/20
  static const int phrasePointsMid = 50;      // 18-19/20
  static const int phrasePointsPerfect = 70;  // 20/20
  static const int phrasePointsLowMin = 15;   // min score for low bracket
  static const int phrasePointsMidMin = 18;   // min score for mid bracket
  static const int phrasePointsPerfectMin = 20; // min score for perfect bracket

  static const String assetsPath = 'assets/data';
  static const String prefsKeyPrefix = 'unit_score_';
  static const String writingScoreKeyPrefix = 'writing_score_';
  static const String prefsDarkModeKey = 'dark_mode';
  static const String prefsThemeKey = 'theme_mode';
  static const String mistakesKey = 'mistakes';

  static int pointsForUnit(String category, int score) {
    switch (category) {
      case 'verbes':
        return score * verbesPointsPerCorrect;
      case 'phrases':
        if (score >= phrasePointsPerfectMin) return phrasePointsPerfect;
        if (score >= phrasePointsMidMin) return phrasePointsMid;
        if (score >= phrasePointsLowMin) return phrasePointsLow;
        return 0;
      case 'noms':
      default:
        return score * nomsPointsPerCorrect;
    }
  }

  /// Local bundled content file for a lesson, keyed by unitNumber (1-15).
  static const List<String> unitFiles = [
    'noms1_colors',
    'noms2_numbers',
    'noms3_animals',
    'noms4_food',
    'noms5_family',
    'verbes1_physical',
    'verbes2_daily',
    'verbes3_movement',
    'verbes4_mental',
    'verbes5_emotions',
    'phrases1_simple',
    'phrases2_daily',
    'phrases3_advanced',
    'phrases4_social',
    'phrases5_expert',
  ];

  static String unitFilePath(int unitNumber) {
    if (unitNumber >= 1 && unitNumber <= unitFiles.length) {
      return '$assetsPath/${unitFiles[unitNumber - 1]}.json';
    }
    return '$assetsPath/noms1_colors.json';
  }

  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'https://myfrenshapp.onrender.com';
  }

  /// Difficulty per unitNumber (1-15) matching the seed.
  static const List<String> unitDifficulties = [
    'Beginner',           // 1 noms colors
    'Beginner',           // 2 noms numbers
    'Elementary',         // 3 noms animals
    'Elementary',         // 4 noms food
    'Intermediate',       // 5 noms family
    'Elementary',         // 6 verbes physical
    'Elementary',         // 7 verbes daily
    'Intermediate',       // 8 verbes movement
    'Upper Intermediate', // 9 verbes mental
    'Advanced',           // 10 verbes emotions
    'Elementary',         // 11 phrases simple
    'Intermediate',       // 12 phrases daily
    'Upper Intermediate', // 13 phrases advanced
    'Advanced',           // 14 phrases social
    'Expert',             // 15 phrases expert
  ];

  /// Title per unitNumber (1-15) matching the seed.
  static const List<String> unitTitles = [
    'Les Couleurs',
    'Les Nombres',
    'Les Animaux',
    'La Nourriture',
    'La Famille',
    'Les Actions Physiques',
    'Les Verbes du Quotidien',
    'Le Mouvement',
    'Les Verbes Mentaux',
    'Les Émotions',
    'Phrases Simples',
    'Phrases du Quotidien',
    'Phrases Avancées',
    'Phrases Sociales',
    'Phrases Expertes',
  ];

  /// Category per unitNumber (1-15).
  static const List<String> unitCategories = [
    'noms', 'noms', 'noms', 'noms', 'noms',
    'verbes', 'verbes', 'verbes', 'verbes', 'verbes',
    'phrases', 'phrases', 'phrases', 'phrases', 'phrases',
  ];

  /// Prerequisites per unitNumber (1-15) or null.
  static const List<List<int>?> unitPrerequisites = [
    null, null, null, null, null,
    null, null, null, null, null,
    [2, 7],
    [3, 8],
    [4, 9],
    [5, 10],
    [5, 10],
  ];
}

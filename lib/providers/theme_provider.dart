import 'package:flutter/material.dart';
import '../services/progress_service.dart';

class ThemeProvider extends ChangeNotifier {
  final ProgressService _progressService;
  late ThemeMode _themeMode;

  ThemeProvider(this._progressService) {
    _themeMode = ThemeMode.light;
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    final isDark = await _progressService.getDarkMode();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _progressService.setDarkMode(_themeMode == ThemeMode.dark);
    notifyListeners();
  }
}

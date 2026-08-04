import 'package:flutter/widgets.dart';
import '../core/constants/app_constants.dart';
import '../data/courses_data.dart';
import '../data/stories_data.dart';
import '../models/course_model.dart';
import '../models/story_model.dart';
import '../models/unit_model.dart';
import '../services/api_service.dart';
import '../services/json_loader_service.dart';

class ContentProvider extends ChangeNotifier {
  final ApiService _api;

  List<Unit> _units = [];
  List<Story> _stories = [];
  List<Course> _courses = [];
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  ContentProvider(this._api);

  List<Unit> get units => _units;
  List<Story> get stories => _stories;
  List<Course> get courses => _courses;
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;

  Future<void> loadAll() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    // Defer the first notification so loadAll can be triggered during build
    // (e.g. from initState) without hitting "setState during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_loading) notifyListeners();
    });
    try {
      _units = await _loadUnits();
      _stories = await _loadStories();
      _courses = await _loadCourses();
      _loaded = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<Unit>> _loadUnits() async {
    if (_api.isAuthenticated) {
      try {
        final remote = await _api.fetchUnits();
        if (remote.isNotEmpty) return remote;
      } catch (_) {
        // Fall back to bundled content when the server is unreachable.
      }
    }
    final units = <Unit>[];
    for (int i = 1; i <= AppConstants.totalUnits; i++) {
      final questions = await loadLocalUnitQuestions(i);
      units.add(Unit(
        unitNumber: i,
        difficulty: AppConstants.unitDifficulties[i - 1],
        questions: questions,
      ));
    }
    return units;
  }

  Future<List<Story>> _loadStories() async {
    if (_api.isAuthenticated) {
      try {
        final remote = await _api.fetchStories();
        if (remote.isNotEmpty) return remote;
      } catch (_) {}
    }
    return kStories;
  }

  Future<List<Course>> _loadCourses() async {
    if (_api.isAuthenticated) {
      try {
        final remote = await _api.fetchCourses();
        if (remote.isNotEmpty) return remote;
      } catch (_) {}
    }
    return kCourses;
  }
}

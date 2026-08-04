import 'package:flutter/widgets.dart';
import '../core/constants/app_constants.dart';
import '../data/courses_data.dart';
import '../data/stories_data.dart';
import '../models/course_model.dart';
import '../models/question_model.dart';
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

  /// Reloads all content from the remote server (used after admin edits).
  Future<void> refreshAll() async {
    if (_loading) return;
    _loading = true;
    _error = null;
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

  // ---------- Admin content operations ----------

  Future<void> adminCreateUnit(
    int unitNumber,
    String difficulty,
    List<Question> questions,
  ) async {
    await _api.adminCreateUnit(
      unitNumber,
      difficulty,
      questions.map((q) => q.toJson()).toList(),
    );
    await refreshAll();
  }

  Future<void> adminUpdateUnitQuestions(
    int unitNumber,
    List<Question> questions,
  ) async {
    await _api.adminUpdateUnit(
      unitNumber,
      questions: questions.map((q) => q.toJson()).toList(),
    );
    await refreshAll();
  }

  Future<void> adminUpdateUnitMeta(
    int unitNumber, {
    String? difficulty,
    List<Question>? questions,
  }) async {
    await _api.adminUpdateUnit(
      unitNumber,
      difficulty: difficulty,
      questions: questions?.map((q) => q.toJson()).toList(),
    );
    await refreshAll();
  }

  Future<void> adminDeleteUnit(int unitNumber) async {
    await _api.adminDeleteUnit(unitNumber);
    await refreshAll();
  }

  Future<void> adminCreateStory(Story story) async {
    await _api.adminCreateStory(
      title: story.title,
      content: story.content,
      questions: story.questions.map((q) => q.toJson()).toList(),
    );
    await refreshAll();
  }

  Future<void> adminUpdateStory(int id, Story story) async {
    await _api.adminUpdateStory(
      id,
      title: story.title,
      content: story.content,
      questions: story.questions.map((q) => q.toJson()).toList(),
    );
    await refreshAll();
  }

  Future<void> adminDeleteStory(int id) async {
    await _api.adminDeleteStory(id);
    await refreshAll();
  }

  Future<void> adminCreateCourse(Course course) async {
    await _api.adminCreateCourse(
      title: course.title,
      description: course.description,
      iconKey: course.iconKey,
      lessons: course.lessons.map((l) => l.toJson()).toList(),
      questions: course.questions.map((q) => q.toJson()).toList(),
    );
    await refreshAll();
  }

  Future<void> adminUpdateCourse(int id, Course course) async {
    await _api.adminUpdateCourse(
      id,
      title: course.title,
      description: course.description,
      iconKey: course.iconKey,
      lessons: course.lessons.map((l) => l.toJson()).toList(),
      questions: course.questions.map((q) => q.toJson()).toList(),
    );
    await refreshAll();
  }

  Future<void> adminDeleteCourse(int id) async {
    await _api.adminDeleteCourse(id);
    await refreshAll();
  }
}

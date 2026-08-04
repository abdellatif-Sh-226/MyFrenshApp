import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/course_model.dart';
import '../models/mistake_model.dart';
import '../models/question_model.dart';
import '../models/story_model.dart';
import '../models/unit_model.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const String _tokenKey = 'api_token';
  static const String _userKey = 'api_user';

  http.Client? _client;
  String? _token;
  Map<String, dynamic>? _user;
  List<Unit>? _unitsCache;
  bool _initialized = false;

  static const Duration _timeout = Duration(seconds: 10);

  http.Client get _http => _client ??= http.Client();

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  String? get username => _user?['username'] as String?;
  bool get isAdmin => _user?['isAdmin'] == true;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final rawUser = prefs.getString(_userKey);
    if (rawUser != null) {
      try {
        _user = json.decode(rawUser) as Map<String, dynamic>;
      } catch (_) {
        _user = null;
      }
    }
    _initialized = true;
  }

  Future<void> _persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    final t = _token;
    final u = _user;
    if (t != null) await prefs.setString(_tokenKey, t);
    if (u != null) await prefs.setString(_userKey, json.encode(u));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<Map<String, dynamic>> register(String username, String password) async {
    final data = await _request(
      'POST',
      '/api/auth/register',
      body: {'username': username, 'password': password},
      auth: false,
    );
    _applySession(data);
    return data;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final data = await _request(
      'POST',
      '/api/auth/login',
      body: {'username': username, 'password': password},
      auth: false,
    );
    _applySession(data);
    return data;
  }

  void _applySession(dynamic data) {
    if (data is! Map<String, dynamic>) return;
    _token = data['token'] as String?;
    _user = data['user'] as Map<String, dynamic>?;
    _unitsCache = null;
    _persistSession();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _unitsCache = null;
    await _clearSession();
  }

  Future<List<Unit>> fetchUnits() async {
    final data = await _request('GET', '/api/units');
    _unitsCache = (data as List<dynamic>)
        .map((e) => Unit.fromJson(e as Map<String, dynamic>))
        .toList();
    return _unitsCache!;
  }

  Future<List<Question>> fetchUnitQuestions(int unitNumber) async {
    final units = _unitsCache ?? await fetchUnits();
    for (final unit in units) {
      if (unit.unitNumber == unitNumber) return unit.questions;
    }
    throw ApiException('Unit $unitNumber not found');
  }

  Future<List<Story>> fetchStories() async {
    final data = await _request('GET', '/api/stories');
    return (data as List<dynamic>)
        .map((e) => Story.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Course>> fetchCourses() async {
    final data = await _request('GET', '/api/courses');
    return (data as List<dynamic>)
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> fetchProgress() async {
    final data = await _request('GET', '/api/me/progress');
    return data as Map<String, dynamic>;
  }

  Future<void> saveScore(int unitNumber, int score) async {
    await _request(
      'PUT',
      '/api/me/progress/$unitNumber',
      body: {'score': score},
    );
  }

  Future<void> saveWritingScore(int unitNumber, int score) async {
    await _request(
      'PUT',
      '/api/me/writing/$unitNumber',
      body: {'score': score},
    );
  }

  Future<void> saveMistakes(List<Mistake> mistakes) async {
    await _request(
      'POST',
      '/api/me/mistakes',
      body: {
        'mistakes': mistakes.map((m) => m.toApiJson()).toList(),
      },
    );
  }

  Future<void> resetProgress() async {
    await _request('DELETE', '/api/me/progress');
  }

  Future<Map<String, dynamic>?> updatePhoto(String base64Photo) async {
    final data = await _request('PUT', '/api/me/photo', body: {'photo': base64Photo});
    return data as Map<String, dynamic>?;
  }

  Future<void> removePhoto() async {
    await _request('DELETE', '/api/me/photo');
  }

  Future<List<Map<String, dynamic>>> fetchFriends() async {
    final data = await _request('GET', '/api/friends');
    return (data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>> fetchFriendRequests() async {
    return (await _request('GET', '/api/friends/requests'))
        as Map<String, dynamic>;
  }

  Future<void> sendFriendRequest(String username) async {
    await _request('POST', '/api/friends/requests', body: {'username': username});
  }

  Future<void> acceptFriendRequest(int id) async {
    await _request('POST', '/api/friends/requests/$id/accept');
  }

  Future<void> declineFriendRequest(int id) async {
    await _request('POST', '/api/friends/requests/$id/decline');
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    final data = await _request('GET', '/api/friends/leaderboard');
    return (data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  // ---------- Admin ----------

  Future<List<Map<String, dynamic>>> fetchAdminUsers() async {
    final data = await _request('GET', '/api/admin/users');
    return (data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<void> adminDeleteUser(int id) async {
    await _request('DELETE', '/api/admin/users/$id');
  }

  Future<void> adminCreateUnit(
    int unitNumber,
    String difficulty,
    List<Map<String, dynamic>> questions,
  ) async {
    await _request(
      'POST',
      '/api/admin/units',
      body: {'unitNumber': unitNumber, 'difficulty': difficulty, 'questions': questions},
    );
  }

  Future<void> adminUpdateUnit(
    int unitNumber, {
    String? difficulty,
    List<Map<String, dynamic>>? questions,
  }) async {
    await _request(
      'PUT',
      '/api/admin/units/$unitNumber',
      body: {
        'difficulty': ?difficulty,
        'questions': ?questions,
      },
    );
  }

  Future<void> adminDeleteUnit(int unitNumber) async {
    await _request('DELETE', '/api/admin/units/$unitNumber');
  }

  Future<Map<String, dynamic>> adminCreateStory({
    required String title,
    required String content,
    required List<Map<String, dynamic>> questions,
  }) async {
    return (await _request(
      'POST',
      '/api/admin/stories',
      body: {'title': title, 'content': content, 'questions': questions},
    )) as Map<String, dynamic>;
  }

  Future<void> adminUpdateStory(
    int id, {
    String? title,
    String? content,
    List<Map<String, dynamic>>? questions,
  }) async {
    await _request(
      'PUT',
      '/api/admin/stories/$id',
      body: {
        'title': ?title,
        'content': ?content,
        'questions': ?questions,
      },
    );
  }

  Future<void> adminDeleteStory(int id) async {
    await _request('DELETE', '/api/admin/stories/$id');
  }

  Future<Map<String, dynamic>> adminCreateCourse({
    required String title,
    String description = '',
    String iconKey = 'school',
    required List<Map<String, dynamic>> lessons,
    required List<Map<String, dynamic>> questions,
  }) async {
    return (await _request(
      'POST',
      '/api/admin/courses',
      body: {
        'title': title,
        'description': description,
        'iconKey': iconKey,
        'lessons': lessons,
        'questions': questions,
      },
    )) as Map<String, dynamic>;
  }

  Future<void> adminUpdateCourse(
    int id, {
    String? title,
    String? description,
    String? iconKey,
    List<Map<String, dynamic>>? lessons,
    List<Map<String, dynamic>>? questions,
  }) async {
    await _request(
      'PUT',
      '/api/admin/courses/$id',
      body: {
        'title': ?title,
        'description': ?description,
        'iconKey': ?iconKey,
        'lessons': ?lessons,
        'questions': ?questions,
      },
    );
  }

  Future<void> adminDeleteCourse(int id) async {
    await _request('DELETE', '/api/admin/courses/$id');
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    if (auth && !isAuthenticated) {
      throw ApiException('Not signed in');
    }
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (auth && _token != null) 'Authorization': 'Bearer $_token',
    };
    final http.Response res;
    try {
      switch (method) {
        case 'GET':
          res = await _http.get(uri, headers: headers).timeout(_timeout);
          break;
        case 'POST':
          res = await _http
              .post(uri, headers: headers, body: json.encode(body ?? {}))
              .timeout(_timeout);
          break;
        case 'PUT':
          res = await _http
              .put(uri, headers: headers, body: json.encode(body ?? {}))
              .timeout(_timeout);
          break;
        case 'DELETE':
          res = await _http.delete(uri, headers: headers).timeout(_timeout);
          break;
        default:
          throw ApiException('Unsupported method $method');
      }
    } on http.ClientException catch (e) {
      throw ApiException('Cannot reach server ($uri): ${e.message}');
    } on TimeoutException {
      throw ApiException('Cannot reach server ($uri): connection timed out');
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Request failed (${res.statusCode})';
      try {
        final decoded = json.decode(res.body);
        if (decoded is Map && decoded['error'] is String) {
          message = decoded['error'] as String;
        }
      } catch (_) {}
      throw ApiException(message);
    }

    if (res.body.isEmpty) return const {};
    return json.decode(res.body);
  }
}

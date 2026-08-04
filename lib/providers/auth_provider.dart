import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api;
  bool _skipped = false;

  AuthProvider(this._api);

  bool get isLoggedIn => _api.isAuthenticated || _skipped;
  bool get isOnline => _api.isAuthenticated;
  String? get username => _api.username;
  Map<String, dynamic>? get user => _api.user;
  bool get isAdmin => _api.isAdmin;
  String? get profilePhoto => _api.user?['profilePhoto'] as String?;

  Future<void> restoreSession() => _api.init();

  Future<void> skipLogin() async {
    _skipped = true;
    notifyListeners();
  }

  Future<String?> login(String username, String password) async {
    try {
      await _api.login(username, password);
      _skipped = false;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> register(String username, String password) async {
    try {
      await _api.register(username, password);
      _skipped = false;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<void> logout() async {
    _skipped = false;
    await _api.logout();
    notifyListeners();
  }

  Future<void> updatePhoto(String base64Photo) async {
    final result = await _api.updatePhoto(base64Photo);
    if (result != null && _api.user != null) {
      _api.user!['profilePhoto'] = result['profilePhoto'];
      notifyListeners();
    }
  }

  Future<void> removePhoto() async {
    await _api.removePhoto();
    if (_api.user != null) {
      _api.user!['profilePhoto'] = null;
      notifyListeners();
    }
  }
}

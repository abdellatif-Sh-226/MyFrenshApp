import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class FriendsProvider extends ChangeNotifier {
  final ApiService _api;

  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _incoming = [];
  List<Map<String, dynamic>> _sent = [];
  List<Map<String, dynamic>> _leaderboard = [];
  bool _loading = false;
  String? _error;

  FriendsProvider(this._api);

  List<Map<String, dynamic>> get friends => _friends;
  List<Map<String, dynamic>> get incoming => _incoming;
  List<Map<String, dynamic>> get sent => _sent;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadAll() async {
    if (!_api.isAuthenticated) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await Future.wait([_loadFriends(), _loadRequests(), _loadLeaderboard()]);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFriends() async {
    _friends = await _api.fetchFriends();
  }

  Future<void> _loadRequests() async {
    final data = await _api.fetchFriendRequests();
    _incoming = ((data['incoming'] as List?) ?? const [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
    _sent = ((data['sent'] as List?) ?? const [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<void> _loadLeaderboard() async {
    _leaderboard = await _api.fetchLeaderboard();
  }

  Future<String?> sendRequest(String username) async {
    try {
      await _api.sendFriendRequest(username);
      await _loadRequests();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> acceptRequest(int id) async {
    await _api.acceptFriendRequest(id);
    await loadAll();
  }

  Future<void> declineRequest(int id) async {
    await _api.declineFriendRequest(id);
    await loadAll();
  }
}

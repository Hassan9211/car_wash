import 'dart:convert';
import 'package:car_wash/features/authentication/model/mock_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUserStore {
  MockUserStore._();
  static final MockUserStore instance = MockUserStore._();

  static const String _prefsUsersKey = 'mock_user_store.users';
  List<MockUser> _users = [];

  Future<void> init() async {
    await loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final usersJson = preferences.getStringList(_prefsUsersKey);
      
      if (usersJson == null) {
        _users = [];
        return;
      }

      _users = usersJson
          .map((item) => MockUser.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _users = [];
    }
  }

  Future<void> saveUser(MockUser user) async {
    _users = [..._users, user];
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final usersJson = _users
          .map((user) => jsonEncode(user.toJson()))
          .toList();
      
      await preferences.setStringList(_prefsUsersKey, usersJson);
    } catch (_) {
      // Ignore persistence errors in mock store
    }
  }

  MockUser? findUser(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      return _users.firstWhere(
        (u) => u.email.trim().toLowerCase() == normalizedEmail,
      );
    } catch (_) {
      return null;
    }
  }

  bool isEmailTaken(String email) {
    return findUser(email) != null;
  }

  Future<void> deleteUser(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    _users = _users
        .where((u) => u.email.trim().toLowerCase() != normalizedEmail)
        .toList();
    await _persist();
  }

  Future<void> clearAll() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_prefsUsersKey);
    _users = [];
  }
}

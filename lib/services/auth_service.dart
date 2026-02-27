import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  final DatabaseService _dbService = DatabaseService();

  Future<bool> login(String email, String password) async {
    final user = await _dbService.loginUser(email, password);
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, 'local-session-${user['id']}');
      await prefs.setString(_userIdKey, user['id'].toString());
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    final result = await _dbService.registerUser(email, password);
    return result != -1;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
}

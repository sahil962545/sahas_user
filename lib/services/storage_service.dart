import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const String _keyAdminPhone = 'admin_phone_number';
  static const String _defaultAdminPhone = '9702402960';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserToken = 'user_token';

  // Secure storage instance
  static const _secureStorage = FlutterSecureStorage();

  /// Retrieves the saved administrator phone number, falling back to the default if none is set.
  static Future<String> getAdminPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAdminPhone) ?? _defaultAdminPhone;
  }

  /// Saves the administrator phone number.
  static Future<bool> saveAdminPhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyAdminPhone, phoneNumber.trim());
  }

  /// Check if user is logged in.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Saves user session details.
  static Future<void> saveLoginSession(String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserEmail, email);
    await saveUserToken(token);
  }

  /// Saves strictly the JWT token in Flutter Secure Storage.
  static Future<void> saveUserToken(String token) async {
    final cleanToken = token.trim();
    if (cleanToken.isNotEmpty) {
      await _secureStorage.write(key: _keyUserToken, value: cleanToken);
    }
  }

  /// Clears user session details.
  static Future<void> clearLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserEmail);
    await _secureStorage.delete(key: _keyUserToken);
  }

  /// Retrieves the saved authentication token securely.
  static Future<String?> getUserToken() async {
    return await _secureStorage.read(key: _keyUserToken);
  }
}

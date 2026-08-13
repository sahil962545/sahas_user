import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class UserService {
  /// Fetches the user profile details using the saved Bearer token.
  static Future<Map<String, dynamic>> fetchUserProfile() async {
    const url = 'https://uapi.ureka.dev/review/v1/user';
    final token = await StorageService.getUserToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    print('[API PROFILE GET] Requesting: $url');
    print('[API PROFILE GET] Headers: $headers');

    final response = await http.get(Uri.parse(url), headers: headers);

    print('[API PROFILE GET] Response code: ${response.statusCode}');
    print('[API PROFILE GET] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map &&
          decoded['success'] == true &&
          decoded['data'] is Map) {
        return Map<String, dynamic>.from(decoded['data']);
      }
    }
    throw Exception(
      'Failed to fetch user profile (Status: ${response.statusCode})',
    );
  }

  /// Changes user password via API call using the saved Bearer token.
  static Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    const url = 'https://uapi.ureka.dev/review/v1/user/change-password';
    final token = await StorageService.getUserToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final bodyData = {'oldPassword': oldPassword, 'newPassword': newPassword};

    print('[API CHANGE PASSWORD] Requesting: $url');
    print('[API CHANGE PASSWORD] Headers: $headers');
    print('[API CHANGE PASSWORD] Body: ${jsonEncode(bodyData)}');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(bodyData),
    );

    print('[API CHANGE PASSWORD] Response code: ${response.statusCode}');
    print('[API CHANGE PASSWORD] Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['success'] == true) {
        return true;
      }
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] != null) {
        throw Exception(decoded['message'].toString());
      }
    } on Exception {
      rethrow;
    } catch (_) {}

    throw Exception(
      'Failed to change password (Status: ${response.statusCode})',
    );
  }
}

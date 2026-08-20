import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ReviewService {
  /// Fetches units from the REST API.
  static Future<List<Map<String, dynamic>>> fetchUnits() async {
    const url = 'https://uapi.ureka.dev/review/v1/unit';
    final token = await StorageService.getUserToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    print('[API GET] Requesting: $url');
    final response = await http.get(Uri.parse(url), headers: headers);
    print('[API GET] Response code: ${response.statusCode}');
    print('[API GET] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['data'] is List) {
        return List<Map<String, dynamic>>.from(decoded['data']);
      }
    }
    throw Exception('Failed to load units');
  }

  /// Submits the review to the REST API.
  static Future<bool> submitReview({
    required String review,
    required String sentiment,
    required String unitId,
  }) async {
    final token = await StorageService.getUserToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    const url = 'https://uapi.ureka.dev/review/v1/review';
    final bodyData = {
      'review': review,
      'sentiment': sentiment.toLowerCase().trim(),
      'unit': unitId,
    };

    print('[API POST] Requesting: $url');
    print('[API POST] Headers: $headers');
    print('[API POST] Body: ${jsonEncode(bodyData)}');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(bodyData),
    );

    print('[API POST] Response code: ${response.statusCode}');
    print('[API POST] Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return decoded['success'] == true;
    }
    throw Exception('Failed to submit review: Status ${response.statusCode}');
  }
}

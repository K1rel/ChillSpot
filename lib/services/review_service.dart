// services/review_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  static Future<void> createReview({
    required String spotId,
    required String text,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/reviews'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "spot_id": spotId,
        "text": text,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create review: ${response.body}');
    }
  }

  static Future<List<dynamic>> getUserReviews() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  
  if (token == null) {
    throw Exception('User not authenticated');
  }

  final response = await http.get(
    Uri.parse('$_baseUrl/reviews/user'),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load reviews: ${response.body}');
  }
}

static Future<List<dynamic>> getReviewsForSpot(String spotId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  
  if (token == null) {
    throw Exception('User not authenticated');
  }

  final response = await http.get(
    Uri.parse('$_baseUrl/reviews/spot/$spotId'),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load reviews: ${response.body}');
  }
}

// Add to review_service.dart
static Future<void> updateReview({
  required String reviewId,
  required String text,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  
  if (token == null) {
    throw Exception('User not authenticated');
  }

  final response = await http.put(
    Uri.parse('$_baseUrl/reviews/$reviewId'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "text": text,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update review: ${response.body}');
  }
}

static Future<void> deleteReview(String reviewId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  
  if (token == null) {
    throw Exception('User not authenticated');
  }

  final response = await http.delete(
    Uri.parse('$_baseUrl/reviews/$reviewId'),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete review: ${response.body}');
  }
}

}
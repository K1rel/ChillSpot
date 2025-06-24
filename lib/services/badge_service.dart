import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:domasna/models/badge_model.dart';

class BadgeService {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  static Future<BadgeCheckResponse> checkAndGetBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/badges/check'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Badge check response status: ${response.statusCode}');
      print('Badge check response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic rawData = json.decode(response.body);
        
        if (rawData == null) {
          return BadgeCheckResponse(newBadges: [], allBadges: []);
        }
        
        if (rawData is! Map<String, dynamic>) {
          throw Exception('Invalid response format: expected Map but got ${rawData.runtimeType}');
        }
        
        return BadgeCheckResponse.fromJson(rawData);
      } else {
        throw Exception('Failed to check badges: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in checkAndGetBadges: $e');
      rethrow;
    }
  }

  static Future<List<AchievementBadge>> getUserBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/badges'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get badges response status: ${response.statusCode}');
      print('Get badges response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic rawData = json.decode(response.body);
        
        if (rawData == null) {
          return [];
        }
        
        if (rawData is! List) {
          throw Exception('Invalid response format: expected List but got ${rawData.runtimeType}');
        }
        
        return rawData.map((json) => AchievementBadge.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user badges: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getUserBadges: $e');
      rethrow;
    }
  }
}

class BadgeCheckResponse {
  final List<AchievementBadge> newBadges;
  final List<AchievementBadge> allBadges;

  BadgeCheckResponse({required this.newBadges, required this.allBadges});

  factory BadgeCheckResponse.fromJson(Map<String, dynamic> json) {
    try {
      return BadgeCheckResponse(
        newBadges: (json['newBadges'] as List? ?? [])
            .map((e) => AchievementBadge.fromJson(e))
            .toList(),
        allBadges: (json['allBadges'] as List? ?? [])
            .map((e) => AchievementBadge.fromJson(e))
            .toList(),
      );
    } catch (e) {
      print('Error parsing BadgeCheckResponse: $e');
      print('Raw JSON: $json');
      rethrow;
    }
  }
}
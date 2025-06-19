import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpotService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  static Future<void> saveSpotToServer({
    required double lat,
    required double lng,
    required String title,
    required String desc,
    required String weather,
  }) async {
    // Get token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/spots'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "latitude": lat,
        "longitude": lng,
        "title": title,
        "description": desc,
        "weather": weather,
        // Removed user_id - backend gets it from token
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save spot: ${response.body}');
    }
  }

  static Future<List<dynamic>> getSpotsByUserId() async {
    // Get token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/spots/user'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load spots: ${response.body}');
    }
  }

static Future<Map<String, dynamic>> getSpotById(String spotId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  
  if (token == null) {
    throw Exception('User not authenticated');
  }
  //ludnica
  final response = await http.get(
    Uri.parse('$_baseUrl/spots/$spotId'),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return {
      ...data,
      'FavoritesCount': data['favorites_count'] ?? data['FavoritesCount'] ?? 0,
      'VisitCount': data['visit_count'] ?? data['VisitCount'] ?? 0,
    };
  }else {
    throw Exception('Failed to load spot: ${response.body}');
  }
}

static Future<void> likeSpot(String spotId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  
  if (token == null)  {
    throw Exception('User not authenticated');
  }

  final response = await http.post(
    Uri.parse('$_baseUrl/spots/$spotId/like'),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to like spot: ${response.body}');
  }
}

static Future<void> trackVisit(String spotId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  
  if (token == null) {
    throw Exception('User not authenticated');
  }

  final response = await http.post(
    Uri.parse('$_baseUrl/spots/$spotId/visit'),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to track visit: ${response.body}');
  }
}

}
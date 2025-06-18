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
}
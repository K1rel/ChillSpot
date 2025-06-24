    import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VisitedSpotService {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  static Future<Map<String, dynamic>> addVisitedSpot({
    required String spotId,
    String notes = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/visited-spots'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "spot_id": spotId,
        "notes": notes,
      }),
    );

   if (response.statusCode == 201) {
    final data = json.decode(response.body);
    return {
      'success': true,
      'xp_gained': data['xp_gained'] ?? 10,
      'visited_spot': data['visited_spot'],
    };
  } else {
    throw Exception('Failed to add visited spot: ${response.body}');
  }
  }

  static Future<List<dynamic>> getVisitedSpots() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/visited-spots'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load visited spots: ${response.body}');
    }
  }

  static Future<List<NearbySpot>> checkProximity({
    required double latitude,
    required double longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/spots/check-proximity'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "latitude": latitude,
        "longitude": longitude,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final nearbySpots = (data['nearby_spots'] as List)
          .map((spot) => NearbySpot.fromJson(spot))
          .toList();
      return nearbySpots;
    } else {
      throw Exception('Failed to check proximity: ${response.body}');
    }
  }
}

class NearbySpot {
  final String spotId;
  final String title;
  final double distance;
  final double latitude;
  final double longitude;

  NearbySpot({
    required this.spotId,
    required this.title,
    required this.distance,
    required this.latitude,
    required this.longitude,
  });

  factory NearbySpot.fromJson(Map<String, dynamic> json) {
    return NearbySpot(
      spotId: json['spot_id'],
      title: json['title'],
      distance: json['distance'].toDouble(),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotService {

 static const String _baseUrl = 'http://10.0.2.2:8080';

  static Future<void> saveSpotToServer({
    required double lat,
    required double lng,
    required String title,
    required String desc,
    required String weather,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/spots'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "latitude": lat,
        "longitude": lng,
        "title": title,
        "description": desc,
        "weather": weather,
        "user_id": userId,
      }),
    );

    if (response.statusCode == 200) {
      print("Spot saved!");
    } else {
      print("Failed to save spot: ${response.body}");
    }
  }
}

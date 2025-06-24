import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpotService {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

 static Future<void> saveSpotToServer({
  required double lat,
  required double lng,
  required String title,
  required String desc,
  required String weather,
   required double altitude,
  required File? dayImage,
  required File? nightImage,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    throw Exception('User not authenticated');
  }

  // Create multipart request
  var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/spots'));
  request.headers['Authorization'] = 'Bearer $token';
  request.fields['altitude'] = altitude.toString();

  // Add text fields
  request.fields['latitude'] = lat.toString();
  request.fields['longitude'] = lng.toString();
  request.fields['title'] = title;
  request.fields['description'] = desc;
  request.fields['weather'] = weather;

  // Add day image if exists
  if (dayImage != null) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'day_image',
        dayImage.path,
        filename: 'day_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    );
  }

  // Add night image if exists
  if (nightImage != null) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'night_image',
        nightImage.path,
        filename: 'night_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    );
  }

  // Send request
  var response = await request.send();
  var responseBody = await response.stream.bytesToString();

  if (response.statusCode != 201) {
    throw Exception('Failed to save spot: $responseBody');
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

  final response = await http.get(
    Uri.parse('$_baseUrl/spots/$spotId'),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // Debug print to see what we're getting
    print('Raw response data: $data');

    // Create the response object with proper image URL construction
    Map<String, dynamic> result = {
      ...data,
      'FavoritesCount': data['favorites_count'] ?? 0,
      'VisitCount': data['visit_count'] ?? 0,
    };

    // Construct image URLs if images exist
    if (data['DayImage'] != null && data['DayImage'].toString().isNotEmpty) {
      result['DayImageUrl'] = '$_baseUrl/images/${data['DayImage']}';
      print('Day image URL: ${result['DayImageUrl']}');
    }

    if (data['NightImage'] != null && data['NightImage'].toString().isNotEmpty) {
      result['NightImageUrl'] = '$_baseUrl/images/${data['NightImage']}';
      print('Night image URL: ${result['NightImageUrl']}');
    }

    return result;
  } else {
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

static String getUrl(){
  return _baseUrl;
}

}

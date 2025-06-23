import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  static Future<http.Response> register(String email, String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
      }),
    );

 return response;
  }

   static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final userId = data['user_id'];
      
      // Store token and user ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('user_id', userId);
      
      return data; // Return the parsed data as Map
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

   static Future<Map<String, dynamic>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$_baseUrl/profile'), // Make sure your backend has this endpoint
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String email,
    required String username,
    File? profileImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Not authenticated');

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$_baseUrl/profile'),
    );

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    request.fields['email'] = email;
    request.fields['username'] = username;

    // Add profile image if exists
    if (profileImage != null) {
      var fileStream = http.ByteStream(profileImage.openRead());
      var length = await profileImage.length();
      
      var multipartFile = http.MultipartFile(
        'profileImage',
        fileStream,
        length,
        filename: profileImage.path.split('/').last,
        contentType: MediaType('image', 'jpeg'), // Adjust based on actual image type
      );
      request.files.add(multipartFile);
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      var errorData = jsonDecode(responseData);
      throw Exception(errorData['message'] ?? 'Failed to update profile');
    }

    return jsonDecode(responseData);
  }
}
  

  


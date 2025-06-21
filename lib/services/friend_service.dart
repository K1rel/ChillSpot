import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FriendService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Map<String, dynamic>>> _handleResponse(
      http.Response response, String listKey) async {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data.cast<Map<String, dynamic>>();
      if (data is Map && data.containsKey(listKey)) {
        return (data[listKey] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } else {
      throw Exception('${response.statusCode} - ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
  try {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/friends/search'),
      headers: headers,
      body: json.encode({'query': query, 'limit': 10}),
    );
    
    print('Search response: ${response.statusCode} ${response.body}'); // Debug
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } else {
      throw Exception('${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Search error: $e');
  }
}

 static Future<String> sendFriendRequest(String receiverId) async {
  try {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/friends/request'),
      headers: headers,
      body: json.encode({'receiver_id': receiverId}),
    );
    
    if (response.statusCode == 201) {
      return 'success';
    } else if (response.statusCode == 409) {
      final body = json.decode(response.body);
      return body['error'] ?? 'Friend request already sent';
    } else {
      return 'Failed to send request: ${response.statusCode}';
    }
  } catch (e) {
    return 'Error: $e';
  }
}

 static Future<List<Map<String, dynamic>>> getFriendRequests() async {
  try {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/friends/requests'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } else {
      throw Exception('${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Get requests error: $e');
  }
}

  static Future<bool> acceptFriendRequest(String requestId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/friends/accept'),
        headers: headers,
        body: json.encode({'request_id': requestId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Accept error: $e');
    }
  }

  static Future<bool> declineFriendRequest(String requestId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/friends/decline'),
        headers: headers,
        body: json.encode({'request_id': requestId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Decline error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getFriends() async {
  try {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/friends'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } else {
      throw Exception('${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Get friends error: $e');
  }
}
}
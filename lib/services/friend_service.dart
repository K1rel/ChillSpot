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

  static Future<List<UserSearchResult>> searchUsers(String query) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/friends/search'),
        headers: headers,
        body: json.encode({'query': query, 'limit': 10}),
      );

      if (response.statusCode == 200) {
        // Parse response as List directly
        final List<dynamic> usersJson = json.decode(response.body);
        
        return usersJson.map((userJson) {
          return UserSearchResult(
            userJson['id']?.toString() ?? '', 
            userJson['username']?.toString() ?? '',
            userJson['email']?.toString() ?? userJson['username']?.toString() ?? '',
            userJson['profile_pic']?.toString(),
          );
        }).toList();
      } else {
        throw Exception('Failed to search users: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> sendFriendRequest(String receiverId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/friends/request'),
        headers: headers,
        body: json.encode({'receiver_id': receiverId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Request error: $e');
    }
  }

  static Future<List<FriendRequest>> getFriendRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/friends/requests'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse response as List directly
        final List<dynamic> requestsJson = json.decode(response.body);
        
        return requestsJson.map((requestJson) {
          final sender = requestJson['sender'] as Map<String, dynamic>? ?? {};
          return FriendRequest(
            requestJson['id']?.toString() ?? '',
            sender['username']?.toString() ?? '',
            sender['email']?.toString() ?? sender['username']?.toString() ?? '',
            sender['profile_pic']?.toString(),
            DateTime.parse(requestJson['created_at']?.toString() ?? DateTime.now().toString()),
          );
        }).toList();
      } else {
        throw Exception('Failed to get requests: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
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

  static Future<List<Friend>> getFriends() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/friends'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse response as List directly
        final List<dynamic> friendsJson = json.decode(response.body);
        
        return friendsJson.map((friendJson) {
          return Friend(
            friendJson['id']?.toString() ?? '',
            friendJson['username']?.toString() ?? '',
            friendJson['email']?.toString() ?? friendJson['username']?.toString() ?? '',
            friendJson['profile_pic']?.toString(),
          );
        }).toList();
      } else {
        throw Exception('Failed to get friends: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

class UserSearchResult {
  final String id;
  final String username;
  final String displayName;
  final String? profilePic;

  UserSearchResult(this.id, this.username, this.displayName, this.profilePic);
}

class FriendRequest {
  final String id;
  final String username;
  final String displayName;
  final String? profilePic;
  final DateTime requestTime;

  FriendRequest(this.id, this.username, this.displayName, this.profilePic, this.requestTime);
}

class Friend {
  final String id;
  final String username;
  final String displayName;
  final String? profilePic;

  Friend(this.id, this.username, this.displayName, this.profilePic);
}
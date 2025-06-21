import 'package:domasna/components/back_button.dart';
import 'package:domasna/services/friend_service.dart';
import 'package:flutter/material.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

 void _searchUsers(String query) async {
  if (query.isEmpty) {
    setState(() => searchResults = []);
    return;
  }

  setState(() => isLoading = true);

  try {
    final results = await FriendService.searchUsers(query);
    print('Search results: $results'); // Debug print
    
    setState(() {
      searchResults = results.map<Map<String, dynamic>>((user) {
        return {
          'id': user['id']?.toString() ?? '',
          'username': user['username']?.toString() ?? '',
          'display_name': user['username']?.toString() ?? '', // Use username for display
          'profile_pic': user['profile_pic']?.toString() ?? '',
        };
      }).toList();
      isLoading = false;
    });
  } catch (e) {
    setState(() => isLoading = false);
    print('Search error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Search error: ${e.toString()}')),
    );
  }
}

  void _sendFriendRequest(Map<String, dynamic> user) async {
  setState(() => isLoading = true);
  
  try {
    final receiverId = user['id']?.toString();
    if (receiverId == null || receiverId.isEmpty) {
      throw Exception('Invalid user ID');
    }

    final result = await FriendService.sendFriendRequest(receiverId);
    if (result == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request sent to ${user['username']}'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => searchResults.remove(user));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() => isLoading = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color.fromRGBO(255, 255, 255, 0.15),
                  BlendMode.lighten,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CustomBackButton(
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Add Friend',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchUsers,
                    decoration: InputDecoration(
                      hintText: 'Search by username or name...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _searchUsers('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : searchResults.isEmpty && _searchController.text.isNotEmpty
                          ? const Center(
                              child: Text(
                                'No users found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : searchResults.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Search for friends by username or name',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
  final user = searchResults[index];
  final username = user['username'] ?? 'Unknown';
  final displayName = user['display_name'] ?? username;
  final profilePic = user['profile_pic'];

  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: CircleAvatar(
        backgroundImage: profilePic != null && profilePic.isNotEmpty
            ? NetworkImage(profilePic)
            : null,
        child: (profilePic == null || profilePic.isEmpty)
            ? Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : '?')
            : null,
      ),
      title: Text(
        displayName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('@$username'),
      trailing: ElevatedButton(
        onPressed: () => _sendFriendRequest(user),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Add'),
      ),
    ),
  );
},
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
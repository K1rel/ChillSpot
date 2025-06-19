// import 'package:domasna/components/back_button.dart';
// import 'package:flutter/material.dart';

// class AddFriendScreen extends StatefulWidget {
//   @override
//   _AddFriendScreenState createState() => _AddFriendScreenState();
// }

// class _AddFriendScreenState extends State<AddFriendScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<UserSearchResult> searchResults = [];
//   bool isLoading = false;

//   // Mock data for demonstration
//   final List<UserSearchResult> allUsers = [
//     UserSearchResult('alice_wanderlust', 'Alice Wanderlust', 'https://via.placeholder.com/50'),
//     UserSearchResult('bob_trail', 'Bob Trailblazer', 'https://via.placeholder.com/50'),
//     UserSearchResult('chloe_hiker', 'Chloe Hiker', 'https://via.placeholder.com/50'),
//     UserSearchResult('david_adventure', 'David Adventure', 'https://via.placeholder.com/50'),
//     UserSearchResult('ella_explorer', 'Ella Explorer', 'https://via.placeholder.com/50'),
//   ];

//   void _searchUsers(String query) {
//     if (query.isEmpty) {
//       setState(() {
//         searchResults = [];
//       });
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     // Simulate API call delay
//     Future.delayed(Duration(milliseconds: 500), () {
//       setState(() {
//         searchResults = allUsers
//             .where((user) =>
//                 user.username.toLowerCase().contains(query.toLowerCase()) ||
//                 user.displayName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         isLoading = false;
//       });
//     });
//   }

//   void _sendFriendRequest(UserSearchResult user) {
//     // TODO: Implement API call to send friend request
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Friend request sent to ${user.displayName}'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('images/background.png'),
//                 fit: BoxFit.cover,
//                 colorFilter: ColorFilter.mode(
//                   Color.fromRGBO(255, 255, 255, 0.15),
//                   BlendMode.lighten,
//                 ),
//               ),
//             ),
//           ),
//           SafeArea(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     children: [
//                       CustomBackButton(
//                         onTap: () => Navigator.pop(context),
//                       ),
//                       const SizedBox(width: 16),
//                       const Text(
//                         'Add Friend',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: _searchUsers,
//                     decoration: InputDecoration(
//                       hintText: 'Search by username or name...',
//                       prefixIcon: const Icon(Icons.search),
//                       suffixIcon: _searchController.text.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(Icons.clear),
//                               onPressed: () {
//                                 _searchController.clear();
//                                 _searchUsers('');
//                               },
//                             )
//                           : null,
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Expanded(
//                   child: isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : searchResults.isEmpty && _searchController.text.isNotEmpty
//                           ? const Center(
//                               child: Text(
//                                 'No users found',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             )
//                           : searchResults.isEmpty
//                               ? const Center(
//                                   child: Text(
//                                     'Search for friends by username or name',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 )
//                               : ListView.builder(
//                                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                                   itemCount: searchResults.length,
//                                   itemBuilder: (context, index) {
//                                     final user = searchResults[index];
//                                     return Card(
//                                       margin: const EdgeInsets.only(bottom: 8),
//                                       color: Colors.white,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       elevation: 2,
//                                       child: ListTile(
//                                         contentPadding: const EdgeInsets.all(12),
//                                         leading: CircleAvatar(
//                                           backgroundImage: user.profilePic != null
//                                               ? NetworkImage(user.profilePic!)
//                                               : null,
//                                           child: user.profilePic == null
//                                               ? Text(user.displayName[0].toUpperCase())
//                                               : null,
//                                         ),
//                                         title: Text(
//                                           user.displayName,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         subtitle: Text('@${user.username}'),
//                                         trailing: ElevatedButton(
//                                           onPressed: () => _sendFriendRequest(user),
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.orange,
//                                             foregroundColor: Colors.white,
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 16,
//                                               vertical: 8,
//                                             ),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius: BorderRadius.circular(8),
//                                             ),
//                                           ),
//                                           child: const Text('Add'),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }

// class UserSearchResult {
//   final String username;
//   final String displayName;
//   final String? profilePic;

//   UserSearchResult(this.username, this.displayName, this.profilePic);
// }

import 'package:domasna/components/back_button.dart';
import 'package:domasna/services/friend_service.dart';
import 'package:flutter/material.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserSearchResult> searchResults = [];
  bool isLoading = false;

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final results = await FriendService.searchUsers(query);
      setState(() {
        searchResults = results.cast<UserSearchResult>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching users: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendFriendRequest(UserSearchResult user) async {
    final success = await FriendService.sendFriendRequest(user.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request sent to ${user.displayName}'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Remove user from search results after sending request
      setState(() {
        searchResults.remove(user);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send friend request'),
          backgroundColor: Colors.red,
        ),
      );
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
                                          backgroundImage: user.profilePic != null
                                              ? NetworkImage(user.profilePic!)
                                              : null,
                                          child: user.profilePic == null
                                              ? Text(user.displayName[0].toUpperCase())
                                              : null,
                                        ),
                                        title: Text(
                                          user.displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text('@${user.username}'),
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

class UserSearchResult {
  final String id;
  final String username;
  final String displayName;
  final String? profilePic;

  UserSearchResult(this.id, this.username, this.displayName, this.profilePic);
}
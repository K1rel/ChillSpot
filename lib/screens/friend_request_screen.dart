// import 'package:domasna/components/back_button.dart';
// import 'package:flutter/material.dart';

// class FriendRequestsScreen extends StatefulWidget {
//   @override
//   _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
// }

// class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
//   List<FriendRequest> friendRequests = [
//     FriendRequest('mike_climber', 'Mike Climber', 'https://via.placeholder.com/50', DateTime.now().subtract(Duration(hours: 2))),
//     FriendRequest('sarah_trail', 'Sarah Trail', 'https://via.placeholder.com/50', DateTime.now().subtract(Duration(days: 1))),
//     FriendRequest('tom_adventure', 'Tom Adventure', 'https://via.placeholder.com/50', DateTime.now().subtract(Duration(days: 2))),
//   ];

//   void _acceptFriendRequest(FriendRequest request) {
//     // TODO: Implement API call to accept friend request
//     setState(() {
//       friendRequests.remove(request);
//     });
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('You are now friends with ${request.displayName}'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   void _declineFriendRequest(FriendRequest request) {
//     // TODO: Implement API call to decline friend request
//     setState(() {
//       friendRequests.remove(request);
//     });
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Friend request from ${request.displayName} declined'),
//         backgroundColor: Colors.orange,
//       ),
//     );
//   }

//   String _getTimeAgo(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);

//     if (difference.inDays > 0) {
//       return '${difference.inDays}d ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m ago';
//     } else {
//       return 'Just now';
//     }
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
//                         'Friend Requests',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const Spacer(),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.orange,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           '${friendRequests.length}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: friendRequests.isEmpty
//                       ? const Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.person_add_disabled,
//                                 size: 64,
//                                 color: Colors.grey,
//                               ),
//                               SizedBox(height: 16),
//                               Text(
//                                 'No friend requests',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.grey,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 'When someone sends you a friend request,\nit will appear here.',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       : ListView.builder(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           itemCount: friendRequests.length,
//                           itemBuilder: (context, index) {
//                             final request = friendRequests[index];
//                             return Card(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               color: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               elevation: 4,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Column(
//                                   children: [
//                                     Row(
//                                       children: [
//                                         CircleAvatar(
//                                           radius: 25,
//                                           backgroundImage: request.profilePic != null
//                                               ? NetworkImage(request.profilePic!)
//                                               : null,
//                                           child: request.profilePic == null
//                                               ? Text(
//                                                   request.displayName[0].toUpperCase(),
//                                                   style: const TextStyle(
//                                                     fontSize: 20,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 )
//                                               : null,
//                                         ),
//                                         const SizedBox(width: 16),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 request.displayName,
//                                                 style: const TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 '@${request.username}',
//                                                 style: const TextStyle(
//                                                   fontSize: 14,
//                                                   color: Colors.grey,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 _getTimeAgo(request.requestTime),
//                                                 style: const TextStyle(
//                                                   fontSize: 12,
//                                                   color: Colors.grey,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 16),
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: ElevatedButton(
//                                             onPressed: () => _declineFriendRequest(request),
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: Colors.grey[300],
//                                               foregroundColor: Colors.black,
//                                               elevation: 2,
//                                               padding: const EdgeInsets.symmetric(vertical: 12),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.circular(8),
//                                               ),
//                                             ),
//                                             child: const Text(
//                                               'Decline',
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           child: ElevatedButton(
//                                             onPressed: () => _acceptFriendRequest(request),
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: Colors.green,
//                                               foregroundColor: Colors.white,
//                                               elevation: 2,
//                                               padding: const EdgeInsets.symmetric(vertical: 12),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.circular(8),
//                                               ),
//                                             ),
//                                             child: const Text(
//                                               'Accept',
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class FriendRequest {
//   final String username;
//   final String displayName;
//   final String? profilePic;
//   final DateTime requestTime;

//   FriendRequest(this.username, this.displayName, this.profilePic, this.requestTime);
// }

import 'package:domasna/components/back_button.dart';
import 'package:domasna/services/friend_service.dart';
import 'package:flutter/material.dart';

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<FriendRequest> friendRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

  void _loadFriendRequests() async {
    try {
      final requests = await FriendService.getFriendRequests();
      setState(() {
        friendRequests = requests.cast<FriendRequest>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading friend requests: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _acceptFriendRequest(FriendRequest request) async {
    final success = await FriendService.acceptFriendRequest(request.id);
    
    if (success) {
      setState(() {
        friendRequests.remove(request);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are now friends with ${request.displayName}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept friend request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _declineFriendRequest(FriendRequest request) async {
    final success = await FriendService.declineFriendRequest(request.id);
    
    if (success) {
      setState(() {
        friendRequests.remove(request);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request from ${request.displayName} declined'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to decline friend request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
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
                        'Friend Requests',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${friendRequests.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : friendRequests.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_add_disabled,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No friend requests',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'When someone sends you a friend request,\nit will appear here.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: friendRequests.length,
                          itemBuilder: (context, index) {
                            final request = friendRequests[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundImage: request.profilePic != null
                                              ? NetworkImage(request.profilePic!)
                                              : null,
                                          child: request.profilePic == null
                                              ? Text(
                                                  request.displayName[0].toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                request.displayName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '@${request.username}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                _getTimeAgo(request.requestTime),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _declineFriendRequest(request),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[300],
                                              foregroundColor: Colors.black,
                                              elevation: 2,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Decline',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _acceptFriendRequest(request),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              elevation: 2,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Accept',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
}

class FriendRequest {
  final String id;
  final String username;
  final String displayName;
  final String? profilePic;
  final DateTime requestTime;

  FriendRequest(this.id, this.username, this.displayName, this.profilePic, this.requestTime);
}
import 'package:domasna/components/profile_button.dart';
import 'package:domasna/screens/added_spots_screen.dart';
import 'package:domasna/screens/home_screen.dart';
import 'package:domasna/screens/map_screen.dart';
import 'package:domasna/screens/leaderboard_screen.dart';
import 'package:domasna/screens/profile_edit_screen.dart';
import 'package:domasna/screens/badges_screen.dart';
import 'package:domasna/screens/review_screen.dart';
import 'package:domasna/screens/visited_spots_screen.dart';
import 'package:flutter/material.dart';
import 'package:domasna/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _username;
  String? _profilePic;
  bool _isLoading = true;
  String? _error;
  int _xp = 0; // Add XP field
  int _level = 1; // Add level field

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Calculate level based on XP (100 XP per level)
  void _calculateLevel() {
    setState(() {
      _level = (_xp ~/ 100) + 1;
    });
  }

  // Calculate progress for current level (0.0 to 1.0)
  double _calculateProgress() {
    final currentLevelXp = _xp % 100;
    return currentLevelXp / 100.0;
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final userData = await AuthService.getUserProfile();
      
      setState(() {
        _username = userData['username'];
        _profilePic = userData['profile_pic'];
        _xp = userData['xp'] ?? 0; // Get XP from backend
        _calculateLevel(); // Calculate level based on XP
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    final currentLevelXp = _xp % 100;
    final nextLevelXp = 100 - currentLevelXp;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 58, 77, 37),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('images/background.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Transform.translate(
                              offset: const Offset(40, -40),
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF162927),
                                    width: 10,
                                  ),
                                ),
                                child:_buildProfileImage(),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _username?.toUpperCase() ?? 'USERNAME',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Level display with XP details
                              Row(
                                children: [
                                  Text(
                                    'Level $_level',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_xp XP',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              // XP progress bar with labels
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.5,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.white,
                                        color: const Color.fromARGB(255, 30, 46, 23),
                                        minHeight: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$currentLevelXp/100',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        'Next level: $nextLevelXp XP',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ProfileButton(
                                      text: 'Explore',
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MapScreen()),
                                      ),
                                    ),
                                    ProfileButton(
                                      text: 'Friends',
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LeaderboardScreen()),
                                      ),
                                    ),
                                    ProfileButton(
                                      text: 'Badges',
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => BadgesScreen()),
                                      ),
                                    ),
                                    ProfileButton(
                                      text: 'Added spots',
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddedSpotsScreen(),
                                          ),
                                        ),
                                    ),
                                    ProfileButton(
                                      text: 'Visited Spots',
                                     onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VisitedSpotsScreen(),
                                          ),
                                        ),
                                    ),
                                    ProfileButton(
                                      text: 'My Reviews',
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ReviewScreen()),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileEditScreen()),
                                        );
                                        _loadProfile(); // Refresh after editing
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFFFFF),
                                        foregroundColor:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        minimumSize: const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        'Edit Profile',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChillSpotHome()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFFFFF),
                                        foregroundColor:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        minimumSize: const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        'Log Out',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
  
  Widget _buildProfileImage() {
    if (_profilePic != null && _profilePic!.isNotEmpty) { 
      print('Profile image URL: $_profilePic');
      
      return ClipOval(
        child: Image.network(
          _profilePic!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading profile image: $error');
            print('URL: $_profilePic');
            return _buildDefaultProfileImage();
          },
        ),
      );
    } else {
      print('No profile picture available');
      return _buildDefaultProfileImage();
    }
  }

  Widget _buildDefaultProfileImage() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: 50,
        color: Colors.grey[800],
      ),
    );
  }
}
import 'package:domasna/screens/home_screen.dart';
import 'package:domasna/screens/map_screen.dart';
import 'package:domasna/screens/leaderboard_screen.dart';
import 'package:domasna/screens/profile_edit_screen.dart';
import 'package:domasna/screens/badges_screen.dart';
import 'package:domasna/screens/review_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                // Add a semi-transparent overlay to ensure text readability
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
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('images/profile.jpg'),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'USERNAME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Level 10',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 0.8,
                          backgroundColor: Colors.white,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ProfileButton(
                            text: 'Explore',
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapScreen()),
                              )
                            },
                          ),
                          ProfileButton(
                            text: 'Friends',
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LeaderboardScreen())
                              )
                            },
                          ),
                          ProfileButton(
                            text: 'Badges',
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BadgesScreen())
                              )
                            },
                          ),
                          ProfileButton(
                            text: 'Added spots',
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MapScreen()))
                            },
                          ),
                          ProfileButton(
                            text: 'Visited Spots',
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MapScreen()))
                            },
                          ),
                          ProfileButton(
                            text: 'My Reviews',
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ReviewScreen())
                              )
                            },
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProfileEditScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFFFF),
                              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
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
                              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
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
}

class ProfileButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const ProfileButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFFFFF),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
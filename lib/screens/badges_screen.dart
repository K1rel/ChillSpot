import 'package:domasna/components/back_button.dart';
import 'package:domasna/models/badge_model.dart';
import 'package:domasna/services/badge_service.dart';
import 'package:domasna/services/spot_service.dart';
import 'package:flutter/material.dart';

class BadgesScreen extends StatefulWidget {
  @override
  _BadgesScreenState createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<AchievementBadge> badges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    try {
      // First check for new badges
      final checkResponse = await BadgeService.checkAndGetBadges();
      
      // Then get all badges
      final allBadges = await BadgeService.getUserBadges();
      
      setState(() {
        badges = allBadges;
        isLoading = false;
      });
      
      if (checkResponse.newBadges.isNotEmpty) {
        _showNewBadgesDialog(checkResponse.newBadges);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load badges: $e')),
      );
    }
  }

  void _showNewBadgesDialog(List<AchievementBadge> newBadges) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Badges Earned!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: newBadges.map((badge) => ListTile(
            leading: Image.network(
              '${SpotService.getUrl()}/images/${badge.imagePath}',
              width: 50,
              height: 50,
            ),
            title: Text(badge.name),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getBadgeDescription(String badgeName) {
    switch (badgeName) {
      case 'First Review':
        return 'Write your first review';
      case 'Review Expert':
        return 'Write 10 reviews';
      case 'Explorer':
        return 'Visit 5 locations';
      case 'Seasoned Traveler':
        return 'Visit 20 locations';
      case 'Spot Creator':
        return 'Create 3 spots';
      case 'Community Builder':
        return 'Create 10 spots';
      case 'Socializer':
        return 'Make 5 friends';
      case 'Networker':
        return 'Make 15 friends';
      case 'Liker':
        return 'Like 10 spots';
      case 'Super Fan':
        return 'Like 50 spots';
      default:
        return 'Achieved by completing a milestone';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with overlay
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
                // Back button and title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CustomBackButton(onTap: () => Navigator.pop(context)),
                      const SizedBox(width: 16),
                      Text(
                        'Your Badges',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badges list
                Expanded(
                  child: isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.white))
                    : badges.isEmpty
                      ? Center(
                          child: Text(
                            "No badges earned yet!",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: badges.length,
                          itemBuilder: (context, index) {
                            final badge = badges[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              color: Colors.white.withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Badge image
                                    Image.network(
                                      '${SpotService.getUrl()}/images/${badge.imagePath}',
                                      width: 50,
                                      height: 50,
                                      errorBuilder: (context, error, stackTrace) => 
                                        Icon(Icons.emoji_events, size: 50, color: Colors.amber),
                                    ),
                                    const SizedBox(width: 16),
                                    // Badge details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            badge.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _getBadgeDescription(badge.name),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
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
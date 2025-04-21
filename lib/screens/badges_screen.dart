import 'package:domasna/components/back_button.dart';
import 'package:flutter/material.dart';

class BadgesScreen extends StatelessWidget {
  final List<Badge> badges = [
    Badge(
      icon: 'images/badges/explorer_badge.png',
      title: 'Explorer',
      description: 'Visit 5 different locations',
    ),
    Badge(
      icon: 'images/badges/reviewer_badge.png',
      title: 'Top Reviewer',
      description: 'Write 10 detailed reviews',
    ),
    Badge(
      icon: 'images/badges/pioneer_badge.png',
      title: 'Pioneer',
      description: 'Add 3 new locations to the map',
    ),
  ];

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
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: CustomBackButton(
                        onTap: () => Navigator.pop(context),
                      )),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      return BadgeCard(badge: badges[index]);
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

class BadgeCard extends StatelessWidget {
  final Badge badge;

  const BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset(
              badge.icon,
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    badge.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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
  }
}

class Badge {
  final String icon;
  final String title;
  final String description;

  Badge({
    required this.icon,
    required this.title,
    required this.description,
  });
}

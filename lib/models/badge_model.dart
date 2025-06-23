// models/badge_model.dart
class AchievementBadge {
  final String id;
  final String userId;
  final String name;
  final String imagePath;

  AchievementBadge({
    required this.id,
    required this.userId,
    required this.name,
    required this.imagePath,
  });

  factory AchievementBadge.fromJson(Map<String, dynamic> json) {
    return AchievementBadge(
      id: json['ID'],
      userId: json['UserID'],
      name: json['Name'],
      imagePath: json['ImagePath'],
    );
  }
}
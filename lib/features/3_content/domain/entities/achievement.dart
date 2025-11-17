// lib/features/3_content/domain/entities/achievement.dart
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final int xpReward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.xpReward,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? '',
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'xpReward': xpReward,
    };
  }
}

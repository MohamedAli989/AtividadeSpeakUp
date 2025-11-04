// lib/models/module.dart
class Module {
  final String id;
  final String title;
  final String description;
  final String languageId;
  final int order;

  const Module({
    required this.id,
    required this.title,
    required this.description,
    required this.languageId,
    required this.order,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      languageId: json['languageId'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'languageId': languageId,
      'order': order,
    };
  }
}

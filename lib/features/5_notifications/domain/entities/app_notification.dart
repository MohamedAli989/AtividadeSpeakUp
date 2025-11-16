// lib/features/5_notifications/domain/entities/app_notification.dart
// Entidade que representa uma notificação dentro da aplicação.

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type;

  /// Construtor flexível: aceita tanto as chaves novas (`title`, `body`, `timestamp`,
  /// `isRead`) quanto chaves legadas em Português (`titulo`, `corpo`, `agendadaPara`, `lida`).
  AppNotification({
    required this.id,
    String? userId,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    // alias em Português (legacy)
    String? titulo,
    String? corpo,
    DateTime? agendadaPara,
    bool? lida,
  }) : userId = userId ?? '',
       title = title ?? titulo ?? '',
       body = body ?? corpo ?? '',
       timestamp = timestamp ?? agendadaPara ?? DateTime.now(),
       isRead = isRead ?? lida ?? false,
       type = type ?? 'default';

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    // alias em Português
    bool? lida,
    String? type,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? lida ?? this.isRead,
      type: type ?? this.type,
    );
  }

  /// Aliases para compatibilidade com código legado em Português.
  String get titulo => title;
  String get corpo => body;
  DateTime? get agendadaPara => timestamp;
  bool get lida => isRead;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // suporta chaves em inglês e em Português
    final id = (json['id'] as String?) ?? (json['identifier'] as String?) ?? '';
    final userId = (json['userId'] as String?) ?? '';
    final title = (json['title'] as String?) ?? json['titulo'] as String?;
    final body = (json['body'] as String?) ?? json['corpo'] as String?;
    DateTime? ts;
    if (json['timestamp'] != null) {
      ts = DateTime.parse(json['timestamp'] as String);
    } else if (json['agendadaPara'] != null) {
      ts = DateTime.parse(json['agendadaPara'] as String);
    }
    final isRead =
        (json['isRead'] as bool?) ?? (json['lida'] as bool?) ?? false;
    final type = (json['type'] as String?) ?? 'default';

    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      body: body,
      timestamp: ts,
      isRead: isRead,
      type: type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }
}

// (Kept single AppNotification definition above.)

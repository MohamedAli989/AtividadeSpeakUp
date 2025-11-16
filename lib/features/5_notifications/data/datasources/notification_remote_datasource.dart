// lib/features/5_notifications/data/datasources/notification_remote_datasource.dart
// Fonte de dados remota usando Cloud Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_notification.dart';

class NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotificationRemoteDataSource([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  Future<List<AppNotification>> fetchNotifications(String userId) async {
    final snap = await _col(
      userId,
    ).orderBy('timestamp', descending: true).get();
    return snap.docs
        .map((d) => AppNotification.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _col(userId).doc(notificationId).update({'isRead': true});
  }

  Stream<int> watchUnreadCount(String userId) {
    return _col(userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}

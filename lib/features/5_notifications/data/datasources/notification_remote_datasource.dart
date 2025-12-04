// lib/features/5_notifications/data/datasources/notification_remote_datasource.dart
// Fonte de dados remota usando Cloud Firestore.

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/app_notification.dart';

class NotificationRemoteDataSource {
  final _supabase = supabase.Supabase.instance.client;

  Future<List<AppNotification>> fetchNotifications(String userId) async {
    final resp = await _supabase
        .from('notifications')
        .select()
        .eq('userId', userId)
        .order('timestamp', ascending: false);
    final list = (resp as List<dynamic>?) ?? [];
    return list
        .map(
          (e) => AppNotification.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'isRead': true})
          .eq('id', notificationId);
    } catch (_) {}
  }

  // Simple polling-based unread count stream (Supabase realtime can be used instead).
  Stream<int> watchUnreadCount(String userId) {
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      final resp = await _supabase
          .from('notifications')
          .select('id')
          .eq('userId', userId)
          .eq('isRead', false);
      final list = (resp as List<dynamic>?) ?? [];
      return list.length;
    });
  }
}

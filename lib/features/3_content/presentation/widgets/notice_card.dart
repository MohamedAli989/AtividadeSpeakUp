// lib/features/3_content/presentation/widgets/notice_card.dart
import 'package:flutter/material.dart';
import 'package:pprincipal/features/3_content/domain/entities/notice.dart';
import 'package:pprincipal/core/utils/colors.dart';

class NoticeCard extends StatelessWidget {
  final Notice notice;
  const NoticeCard({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              notice.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.language, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  notice.language,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const Spacer(),
                Text(
                  '${notice.date.day}/${notice.date.month}/${notice.date.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const Divider(),
            Text(notice.description, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pprincipal/core/utils/colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.buttonLabel,
    this.onButtonPressed,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, size: 56, color: AppColors.secondary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (buttonLabel != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onButtonPressed,
              child: Text(buttonLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

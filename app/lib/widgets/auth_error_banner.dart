import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';

/// Kotak error autentikasi yang dipakai login dan register.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = MonexPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.dangerMuted,
        borderRadius: BorderRadius.circular(MonexSpacing.radiusMd),
        border: Border.all(color: palette.danger.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: palette.danger,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: palette.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

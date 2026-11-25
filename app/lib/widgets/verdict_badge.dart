import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../models/price_verdict.dart';

/// Badge visual untuk [PriceVerdict] yang membaca properti polimorfik
/// (ikon, label, warna, dan emphasis).
class VerdictBadge extends StatelessWidget {
  const VerdictBadge({
    super.key,
    required this.verdict,
    this.compact = false,
  });

  final PriceVerdict verdict;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = verdict.color;
    final horizontalPadding = compact ? 10.0 : 12.0 * verdict.emphasis;
    final verticalPadding = compact ? 5.0 : 7.0 * verdict.emphasis;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(MonexSpacing.radiusPill),
        border: Border.all(
          color: color.withValues(alpha: 0.45),
          width: verdict.emphasis > 1.0 ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(verdict.icon, size: compact ? 14 : 16, color: color),
          const SizedBox(width: 6),
          Text(
            verdict.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

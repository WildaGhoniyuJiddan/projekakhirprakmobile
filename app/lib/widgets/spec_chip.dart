import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';

/// Chip label + nilai spesifikasi pada detail produk.
class SpecChip extends StatelessWidget {
  const SpecChip({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: MonexColors.surfaceElevated,
        borderRadius: BorderRadius.circular(MonexSpacing.radiusSm),
        border: Border.all(color: MonexColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

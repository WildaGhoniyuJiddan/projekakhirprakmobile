import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/product_series.dart';

/// Kartu etalase: satu kartu mewakili satu seri produk.
class ProductSeriesCard extends StatelessWidget {
  const ProductSeriesCard({
    super.key,
    required this.series,
    required this.onTap,
  });

  final ProductSeries series;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MonexSurfaceCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      radius: MonexSpacing.radiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(MonexSpacing.radiusMd),
                  ),
                  child: Image.asset(
                    series.imageAsset,
                    fit: BoxFit.cover,
                    semanticLabel: 'Ilustrasi ${series.categoryLabel}',
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: MonexColors.canvas.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(
                        MonexSpacing.radiusPill,
                      ),
                      border: Border.all(color: MonexColors.borderLight),
                    ),
                    child: Text(
                      series.categoryLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: MonexColors.lime,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  series.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  '${series.variantCount} varian',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Mulai ${formatRupiah(series.minPrice)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: MonexColors.lime,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

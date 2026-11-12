import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/catalog_item.dart';
import '../models/product_series.dart';
import '../widgets/spec_chip.dart';
import 'price_check_screen.dart';

/// Detail satu seri: spesifikasi, daftar varian, dan aksi cek harga.
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.series,
    this.sourceLabel = 'Etalase',
  });

  final ProductSeries series;
  final String sourceLabel;

  void _openPriceCheck(BuildContext context, {String? query}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PriceCheckScreen(initialQuery: query ?? series.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MonexAppBar(
        title: series.name,
        subtitle: '$sourceLabel · ${series.categoryLabel}',
        showBack: true,
        actions: [
          MonexCircleIconButton(
            icon: Icons.price_check_rounded,
            tooltip: 'Cek harga seri',
            onTap: () => _openPriceCheck(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            MonexSpacing.screenPaddingH,
            MonexSpacing.screenPaddingV,
            MonexSpacing.screenPaddingH,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SeriesHeader(series: series),
              const SizedBox(height: MonexSpacing.sectionGap),
              Text('Spesifikasi', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in series.specs.entries)
                    SpecChip(label: entry.key, value: entry.value),
                ],
              ),
              const SizedBox(height: MonexSpacing.sectionGap),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Varian & harga',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '${series.variantCount} produk',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Ketuk varian untuk cek harga model tersebut.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: MonexSpacing.gridGap),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: series.variants.length,
                itemBuilder: (context, index) {
                  final variant = series.variants[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: MonexSpacing.gridGap,
                    ),
                    child: _VariantCard(
                      variant: variant,
                      cheapest: variant.price == series.minPrice,
                      onTap: () =>
                          _openPriceCheck(context, query: variant.model),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              MonexPrimaryButton(
                key: const Key('detail_price_check'),
                label: 'Cek Harga ${series.name}',
                icon: Icons.analytics_outlined,
                onPressed: () => _openPriceCheck(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeriesHeader extends StatelessWidget {
  const _SeriesHeader({required this.series});

  final ProductSeries series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 190,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(MonexSpacing.radiusCard),
            child: Image.asset(
              series.imageAsset,
              fit: BoxFit.cover,
              semanticLabel: 'Ilustrasi ${series.categoryLabel}',
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(MonexSpacing.radiusCard),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  MonexColors.canvas.withValues(alpha: 0.05),
                  MonexColors.canvas.withValues(alpha: 0.88),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: MonexColors.canvas.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(MonexSpacing.radiusPill),
                border: Border.all(color: MonexColors.borderLight),
              ),
              child: Text(
                series.categoryLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: MonexColors.lime,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  series.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  series.priceRangeLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: MonexColors.lime,
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

class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.variant,
    required this.cheapest,
    required this.onTap,
  });

  final CatalogItem variant;
  final bool cheapest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MonexSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: MonexSpacing.radiusMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: MonexColors.limeMuted,
              borderRadius: BorderRadius.circular(MonexSpacing.radiusSm),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: MonexColors.lime,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variant.model,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      formatRupiah(variant.price),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: MonexColors.lime,
                      ),
                    ),
                    if (cheapest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: MonexColors.limeMuted,
                          borderRadius: BorderRadius.circular(
                            MonexSpacing.radiusPill,
                          ),
                        ),
                        child: Text(
                          'Termurah',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            color: MonexColors.lime,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: MonexColors.textMuted,
          ),
        ],
      ),
    );
  }
}

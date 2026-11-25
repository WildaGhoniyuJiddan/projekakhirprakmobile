import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/price_analysis.dart';
import '../state/app_scope.dart';
import '../widgets/verdict_badge.dart';
import '../widgets/wishlist_form_dialog.dart';
import 'converter_screen.dart';
import 'nearby_stores_screen.dart';

/// Halaman hasil analisis kelayakan harga dan daftar pembanding katalog.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.analysis});

  final PriceAnalysis analysis;

  Future<void> _saveToWishlist(BuildContext context) async {
    final suggestedPrice = analysis.referencePrice > 0
        ? analysis.fairPriceLow
        : analysis.request.price;

    final item = await WishlistFormDialog.show(
      context,
      initialQuery: analysis.request.query,
      initialTargetPrice: suggestedPrice,
      initialCondition: analysis.request.condition,
    );
    if (item == null || !context.mounted) return;

    final scope = AppScope.of(context);
    try {
      await scope.wishlistRepository.add(item);
      try {
        await scope.notificationService.showImmediate(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          title: 'Wishlist Ditambahkan 🎯',
          body:
              '${item.query} berhasil disimpan dengan target ${formatRupiah(item.targetPrice)}.',
        );
      } on Object {
        // Notifikasi bersifat non-blocking terhadap UI.
      }

      if (!context.mounted) return;
      showMonexToast(context, 'Disimpan ke wishlist.', isSuccess: true);
    } on Object {
      if (!context.mounted) return;
      showMonexToast(context, 'Gagal menyimpan ke wishlist.', isError: true);
    }
  }

  String _diffLabel() {
    if (analysis.referencePrice <= 0) return '-';
    final diff = analysis.request.price - analysis.referencePrice;
    final pct = ((diff / analysis.referencePrice) * 100).round();
    final sign = diff > 0 ? '+' : '';
    return '$sign$pct% ($sign${formatRupiah(diff)})';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verdict = analysis.verdict;
    final hasReference = analysis.referencePrice > 0;

    return Scaffold(
      appBar: MonexAppBar(
        title: 'Hasil Analisis',
        subtitle: analysis.request.query,
        showBack: true,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MonexSurfaceCard(
                borderColor: verdict.color.withValues(alpha: 0.4),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        VerdictBadge(verdict: verdict),
                        Text(
                          '${analysis.score.round()}/100',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: verdict.color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    MonexProgressBar(
                      value: analysis.score / 100,
                      color: verdict.color,
                    ),
                    const SizedBox(height: 14),
                    Text(verdict.advice, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: MonexSpacing.sectionGap),
              MonexSurfaceCard(
                padding: const EdgeInsets.all(MonexSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ringkasan harga', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: 'Harga ditawarkan',
                      value: formatRupiah(analysis.request.price),
                      highlight: true,
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Median pasar',
                      value: hasReference
                          ? formatRupiah(analysis.referencePrice)
                          : 'Belum tersedia',
                    ),
                    if (hasReference) ...[
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Rentang wajar',
                        value:
                            '${formatRupiah(analysis.fairPriceLow)} – ${formatRupiah(analysis.fairPriceHigh)}',
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Selisih median',
                        value: _diffLabel(),
                        valueColor: verdict.color,
                      ),
                    ],
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Kondisi',
                      value: formatCondition(analysis.request.condition),
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Waktu cek',
                      value: formatDate(analysis.createdAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MonexSpacing.sectionGap),
              Text(
                'Pembanding pasar (${analysis.comparisons.length})',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              if (analysis.comparisons.isEmpty)
                MonexSurfaceCard(
                  padding: const EdgeInsets.all(MonexSpacing.cardPadding),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        color: MonexColors.textMuted,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Belum ada pembanding yang cocok di katalog untuk "${analysis.request.query}".',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                MonexSurfaceCard(
                  padding: const EdgeInsets.all(MonexSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sebaran harga pembanding',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      MonexMiniVerticalBars(
                        values: analysis.comparisons
                            .map((item) => item.price.toDouble())
                            .toList(),
                        highlightIndex: 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MonexSpacing.gridGap),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: analysis.comparisons.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: MonexSpacing.gridGap),
                  itemBuilder: (context, index) {
                    final item = analysis.comparisons[index];
                    final matchPercent = item.similarity == null
                        ? null
                        : '${(item.similarity! * 100).round()}% cocok';
                    return MonexSurfaceCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      radius: MonexSpacing.radiusMd,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  matchPercent == null
                                      ? item.source
                                      : '${item.source} · $matchPercent',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formatRupiah(item.price),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: MonexColors.lime,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: MonexSpacing.sectionGap + 6),
              MonexPrimaryButton(
                key: const Key('result_save_wishlist'),
                label: 'Simpan ke Wishlist',
                icon: Icons.favorite_border_rounded,
                onPressed: () => _saveToWishlist(context),
              ),
              const SizedBox(height: MonexSpacing.gridGap),
              MonexSecondaryButton(
                key: const Key('result_nearby_stores'),
                label: 'Lihat Toko Terdekat',
                icon: Icons.pin_drop_outlined,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => NearbyStoresScreen(
                      initialQuery: analysis.request.query,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: MonexSpacing.gridGap),
              MonexSecondaryButton(
                key: const Key('result_convert_currency'),
                label: 'Konversi ke Mata Uang Asing',
                icon: Icons.currency_exchange_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ConverterScreen(
                      initialAmountIdr: analysis.request.price,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: MonexSpacing.gridGap),
              MonexSecondaryButton(
                key: const Key('result_done'),
                label: 'Selesai',
                icon: Icons.check_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool highlight;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? (highlight ? MonexColors.lime : null),
            ),
          ),
        ),
      ],
    );
  }
}

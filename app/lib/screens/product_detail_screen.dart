import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_ui_colors.dart';
import '../core/theme/monex_theme.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/catalog_item.dart';
import '../models/currency_rate.dart';
import '../models/product_series.dart';
import '../services/currency_api.dart';
import '../state/app_scope.dart';
import '../widgets/spec_chip.dart';
import '../widgets/wishlist_form_dialog.dart';
import 'price_check_screen.dart';

/// Detail satu seri: spesifikasi, konversi kurs, daftar varian, dan cek harga.
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

  Future<void> _addToWishlist(BuildContext context) async {
    final item = await WishlistFormDialog.show(
      context,
      initialQuery: series.name,
      initialTargetPrice: series.minPrice,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = MonexPalette.of(context);

    return Scaffold(
      appBar: MonexAppBar(
        title: series.name,
        subtitle: '$sourceLabel · ${series.categoryLabel}',
        showBack: true,
        actions: [
          MonexCircleIconButton(
            icon: Icons.favorite_border_rounded,
            tooltip: 'Simpan ke wishlist',
            onTap: () => _addToWishlist(context),
          ),
          const SizedBox(width: 8),
          MonexCircleIconButton(
            icon: Icons.price_check_rounded,
            tooltip: 'Cek harga seri',
            onTap: () => _openPriceCheck(context),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                MonexSpacing.screenPaddingH,
                MonexSpacing.screenPaddingV,
                MonexSpacing.screenPaddingH,
                MonexSpacing.gridGap,
              ),
              sliver: SliverToBoxAdapter(
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
                    _CurrencyConversionCard(
                      minPrice: series.minPrice,
                      maxPrice: series.maxPrice,
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
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                MonexSpacing.screenPaddingH,
                0,
                MonexSpacing.screenPaddingH,
                20,
              ),
              sliver: SliverList.builder(
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(top: BorderSide(color: palette.borderSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              MonexSpacing.screenPaddingH,
              12,
              MonexSpacing.screenPaddingH,
              12,
            ),
            child: MonexPrimaryButton(
              key: const Key('detail_price_check'),
              label: 'Cek Harga ${series.name}',
              icon: Icons.analytics_outlined,
              backgroundColor: AppUiColors.of(context).detailCekHargaBg,
              foregroundColor: AppUiColors.of(context).detailCekHargaText,
              onPressed: () => _openPriceCheck(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu konversi harga seri produk ke mata uang asing berbasis HTTP publik.
class _CurrencyConversionCard extends StatefulWidget {
  const _CurrencyConversionCard({
    required this.minPrice,
    required this.maxPrice,
  });

  final int minPrice;
  final int maxPrice;

  @override
  State<_CurrencyConversionCard> createState() =>
      _CurrencyConversionCardState();
}

class _CurrencyConversionCardState extends State<_CurrencyConversionCard> {
  List<CurrencyRate> _rates = const [];
  String _selectedCode = 'USD';
  bool _loading = true;
  String? _error;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _loadRates();
  }

  CurrencyRate? get _selectedRate {
    if (_rates.isEmpty) return null;
    for (final rate in _rates) {
      if (rate.code == _selectedCode) return rate;
    }
    return _rates.first;
  }

  Future<void> _loadRates() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rates = await AppScope.of(context).currencyService.fetchRates();
      if (!mounted) return;
      setState(() {
        _rates = rates;
        if (rates.isNotEmpty && !rates.any((r) => r.code == _selectedCode)) {
          _selectedCode = rates.first.code;
        }
        _loading = false;
      });
    } on CurrencyApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _error = 'Kurs tidak dapat dimuat. Pastikan internet aktif.';
        _loading = false;
      });
    }
  }

  String _formatAmount(CurrencyRate rate, int idr) {
    final value = rate.convertFromIdr(idr.toDouble());
    final zeroDecimal = rate.code == 'JPY' || rate.code == 'KRW';
    final formatter = NumberFormat.decimalPatternDigits(
      locale: 'id_ID',
      decimalDigits: zeroDecimal ? 0 : 2,
    );
    return formatter.format(value);
  }

  String _convertedRangeLabel(CurrencyRate rate) {
    final low = _formatAmount(rate, widget.minPrice);
    if (widget.minPrice == widget.maxPrice) {
      return '$low ${rate.code}';
    }
    final high = _formatAmount(rate, widget.maxPrice);
    return '$low – $high ${rate.code}';
  }

  String _idrPerUnitLabel(CurrencyRate rate) {
    if (rate.rate <= 0) return '';
    return '1 ${rate.code} ≈ ${formatRupiah((1 / rate.rate).round())}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = MonexPalette.of(context);
    final selected = _selectedRate;

    return MonexSurfaceCard(
      key: const Key('detail_currency_card'),
      color: AppUiColors.of(context).detailKonversiCardBg,
      padding: const EdgeInsets.all(MonexSpacing.cardPaddingCompact),
      radius: MonexSpacing.radiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: palette.accentSoft,
                  borderRadius: BorderRadius.circular(MonexSpacing.radiusSm),
                ),
                child: Icon(
                  Icons.currency_exchange_rounded,
                  size: 17,
                  color: palette.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konversi Mata Uang',
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      'Estimasi harga seri ini dalam mata uang asing',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('detail_currency_refresh'),
                tooltip: 'Muat ulang kurs',
                icon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: _loading ? null : _loadRates,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                  'Memuat kurs terbaru...',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            )
          else if (_error != null)
            Row(
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 18,
                  color: palette.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_error!, style: theme.textTheme.bodySmall),
                ),
                TextButton(
                  key: const Key('detail_currency_retry'),
                  onPressed: _loadRates,
                  child: const Text('Coba lagi'),
                ),
              ],
            )
          else if (selected != null) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final rate in _rates)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        key: Key('detail_currency_chip_${rate.code}'),
                        label: Text(rate.code),
                        selected: rate.code == selected.code,
                        onSelected: (_) =>
                            setState(() => _selectedCode = rate.code),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              key: const Key('detail_currency_value'),
              _convertedRangeLabel(selected),
              style: theme.textTheme.titleMedium?.copyWith(
                color: palette.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(_idrPerUnitLabel(selected), style: theme.textTheme.bodySmall),
          ],
        ],
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
              cacheWidth: 800,
              filterQuality: FilterQuality.medium,
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
                    color: MonexColors.textPrimary,
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
    final palette = MonexPalette.of(context);

    return MonexSurfaceCard(
      color: AppUiColors.of(context).detailVarianCardBg,
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
              color: palette.accentSoft,
              borderRadius: BorderRadius.circular(MonexSpacing.radiusSm),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: palette.accent,
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
                        color: palette.accent,
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
                          color: palette.accentSoft,
                          borderRadius: BorderRadius.circular(
                            MonexSpacing.radiusPill,
                          ),
                        ),
                        child: Text(
                          'Termurah',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            color: palette.accent,
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
          Icon(Icons.chevron_right_rounded, size: 18, color: palette.textMuted),
        ],
      ),
    );
  }
}

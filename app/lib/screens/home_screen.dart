import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/price_analysis.dart';
import '../models/product_series.dart';
import '../state/app_scope.dart';
import '../widgets/app_logo.dart';
import '../widgets/product_series_card.dart';
import '../widgets/verdict_badge.dart';
import 'converter_screen.dart';
import 'nearby_stores_screen.dart';
import 'price_check_screen.dart';
import 'product_detail_screen.dart';
import 'result_screen.dart';

/// Beranda: ringkasan akun, pintu masuk fitur, dan seri etalase populer.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = AppScope.of(context);
    final user = scope.sessionController.user;
    final firstName = (user?.name ?? 'Tamu').split(' ').first;

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: AppLogo(size: 36, borderRadius: 10),
        ),
        title: const Text('WorthBang'),
        actions: [
          ListenableBuilder(
            listenable: scope.themeController,
            builder: (context, _) {
              final isDark = theme.brightness == Brightness.dark;
              return IconButton(
                tooltip: isDark ? 'Mode terang' : 'Mode gelap',
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
                onPressed: scope.themeController.toggle,
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          MonexSpacing.screenPaddingH,
          MonexSpacing.screenPaddingV,
          MonexSpacing.screenPaddingH,
          24,
        ),
        children: [
          Text(
            'Halo, $firstName!',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cek kelayakan harga komponen PC sebelum membeli.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: MonexSpacing.sectionGap),
          MonexGradientCard(
            onTap: () => _push(context, const PriceCheckScreen()),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: MonexColors.textDark.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(MonexSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.price_check_rounded,
                    size: 26,
                    color: MonexColors.textDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cek Harga',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: MonexColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bandingkan harga dengan median pasar.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: MonexColors.textDark.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: MonexColors.textDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: MonexSpacing.sectionGap),
          _FeaturedSeries(
            onSeeAll: () => onOpenTab(1),
            onOpenSeries: (series) => _push(
              context,
              ProductDetailScreen(series: series, sourceLabel: 'Beranda'),
            ),
          ),
          const SizedBox(height: MonexSpacing.sectionGap),
          Text('Jelajahi fitur', style: theme.textTheme.titleLarge),
          const SizedBox(height: MonexSpacing.gridGap),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: MonexSpacing.gridGap,
            mainAxisSpacing: MonexSpacing.gridGap,
            childAspectRatio: 1.15,
            children: [
              _HomeMenuCard(
                icon: Icons.storefront_outlined,
                title: 'Cari Produk',
                subtitle: 'Etalase seri komponen PC.',
                onTap: () => onOpenTab(1),
              ),
              _HomeMenuCard(
                icon: Icons.favorite_border_rounded,
                title: 'Wishlist',
                subtitle: 'Simpan target harga pilihanmu.',
                onTap: () => onOpenTab(2),
              ),
              _HomeMenuCard(
                icon: Icons.price_check_rounded,
                title: 'Cek Harga',
                subtitle: 'Analisis harga satu komponen.',
                onTap: () => _push(context, const PriceCheckScreen()),
              ),
              _HomeMenuCard(
                icon: Icons.pin_drop_outlined,
                title: 'Toko Terdekat',
                subtitle: 'Peta toko komputer di sekitarmu.',
                onTap: () => _push(context, const NearbyStoresScreen()),
              ),
            ],
          ),
          const SizedBox(height: MonexSpacing.gridGap),
          MonexSurfaceCard(
            key: const Key('home_converter_card'),
            onTap: () => _push(context, const ConverterScreen()),
            padding: const EdgeInsets.all(MonexSpacing.cardPaddingCompact),
            radius: MonexSpacing.radiusMd,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: MonexColors.limeMuted,
                    borderRadius: BorderRadius.circular(MonexSpacing.radiusSm),
                  ),
                  child: const Icon(
                    Icons.currency_exchange_rounded,
                    size: 20,
                    color: MonexColors.lime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Konverter Kurs', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        'Konversi harga komponen dari IDR ke mata uang asing.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: MonexColors.textMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: MonexSpacing.sectionGap),
          _RecentHistorySection(
            onOpenResult: (analysis) =>
                _push(context, ResultScreen(analysis: analysis)),
          ),
        ],
      ),
    );
  }
}

/// Strip horizontal seri populer; memuat katalog sendiri agar Beranda tetap
/// ringan dan punya keadaan loading/error yang jelas.
class _FeaturedSeries extends StatefulWidget {
  const _FeaturedSeries({required this.onSeeAll, required this.onOpenSeries});

  final VoidCallback onSeeAll;
  final ValueChanged<ProductSeries> onOpenSeries;

  @override
  State<_FeaturedSeries> createState() => _FeaturedSeriesState();
}

class _FeaturedSeriesState extends State<_FeaturedSeries> {
  List<ProductSeries>? _series;
  bool _loading = true;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load();
  }

  Future<void> _load() async {
    final catalog = AppScope.of(context).catalogService;
    try {
      final series = await catalog.loadSeries();
      if (!mounted) return;
      setState(() {
        _series = series.take(8).toList();
        _loading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _retry() {
    setState(() => _loading = true);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Etalase populer', style: theme.textTheme.titleLarge),
            ),
            TextButton(
              onPressed: widget.onSeeAll,
              child: const Text('Lihat semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(height: 210, child: _buildContent(theme)),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_loading) {
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => const SizedBox(
          width: 164,
          child: MonexSurfaceCard(
            padding: EdgeInsets.zero,
            radius: MonexSpacing.radiusMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: MonexShimmer(radius: 0)),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MonexShimmer(height: 13, width: 110),
                      SizedBox(height: 8),
                      MonexShimmer(height: 10, width: 70),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final series = _series;
    if (series == null) {
      return MonexSurfaceCard(
        padding: const EdgeInsets.all(MonexSpacing.cardPadding),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, color: MonexColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Etalase belum bisa dimuat.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(onPressed: _retry, child: const Text('Coba lagi')),
          ],
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: series.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final item = series[index];
        return SizedBox(
          width: 164,
          child: ProductSeriesCard(
            series: item,
            onTap: () => widget.onOpenSeries(item),
          ),
        );
      },
    );
  }
}

class _HomeMenuCard extends StatelessWidget {
  const _HomeMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MonexSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(MonexSpacing.cardPaddingCompact),
      radius: MonexSpacing.radiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: MonexColors.limeMuted,
              borderRadius: BorderRadius.circular(MonexSpacing.radiusSm),
            ),
            child: Icon(icon, size: 20, color: MonexColors.lime),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentHistorySection extends StatelessWidget {
  const _RecentHistorySection({required this.onOpenResult});

  final ValueChanged<PriceAnalysis> onOpenResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyRepo = AppScope.of(context).historyRepository;

    return ListenableBuilder(
      listenable: historyRepo,
      builder: (context, _) {
        final records = historyRepo.recent(limit: 3);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Riwayat cek terbaru', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            if (records.isEmpty)
              MonexSurfaceCard(
                padding: const EdgeInsets.all(MonexSpacing.cardPadding),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      color: MonexColors.textMuted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Belum ada riwayat cek harga. Hasil pengecekanmu akan tampil di sini.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  for (var i = 0; i < records.length; i++) ...[
                    if (i > 0) const SizedBox(height: MonexSpacing.gridGap),
                    MonexSurfaceCard(
                      onTap: () => onOpenResult(records[i].analysis),
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
                                  records[i].analysis.request.query,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatRupiah(
                                    records[i].analysis.request.price,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: MonexColors.lime,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          VerdictBadge(
                            verdict: records[i].analysis.verdict,
                            compact: true,
                          ),
                          IconButton(
                            tooltip: 'Hapus riwayat',
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: MonexColors.textMuted,
                            ),
                            onPressed: () =>
                                historyRepo.deleteByKey(records[i].key),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }
}

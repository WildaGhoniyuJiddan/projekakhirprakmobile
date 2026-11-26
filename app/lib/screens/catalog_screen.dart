import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/product_series.dart';
import '../state/app_scope.dart';
import '../widgets/product_series_card.dart';
import 'product_detail_screen.dart';

/// Tab Cari/Etalase: satu kartu untuk satu seri produk dengan lazy SliverGrid.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _search = TextEditingController();

  List<ProductSeries> _allSeries = const [];
  List<ProductSeries> _filteredSeries = const [];
  Object? _error;
  bool _loading = true;
  bool _started = false;
  String _category = 'Semua';

  static const _categories = [
    'Semua',
    'GPU',
    'CPU',
    'Motherboard',
    'RAM',
    'Storage',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final cached = AppScope.of(context).catalogService.cachedSeries;
    if (cached != null) {
      _allSeries = cached;
      _filteredSeries = _computeFiltered(cached, _category, _search.text);
      _loading = false;
      _error = null;
      return;
    }
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final catalog = AppScope.of(context).catalogService;
    try {
      final series = await catalog.loadSeries();
      if (!mounted) return;
      setState(() {
        _allSeries = series;
        _filteredSeries = _computeFiltered(series, _category, _search.text);
        _loading = false;
        _error = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _load();
  }

  void _resetFilters() {
    _search.clear();
    setState(() {
      _category = 'Semua';
      _filteredSeries = _computeFiltered(_allSeries, _category, '');
    });
  }

  void _onQueryChanged(String value) {
    setState(() {
      _filteredSeries = _computeFiltered(_allSeries, _category, value);
    });
  }

  void _onCategorySelected(String category) {
    if (_category == category) return;
    setState(() {
      _category = category;
      _filteredSeries = _computeFiltered(_allSeries, _category, _search.text);
    });
  }

  static List<ProductSeries> _computeFiltered(
    List<ProductSeries> source,
    String category,
    String rawQuery,
  ) {
    final query = rawQuery.trim().toLowerCase();
    if (category == 'Semua' && query.isEmpty) {
      return source;
    }
    return [
      for (final series in source)
        if ((category == 'Semua' || series.categoryLabel == category) &&
            series.matchesQuery(query))
          series,
    ];
  }

  void _openDetail(ProductSeries series) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProductDetailScreen(series: series, sourceLabel: 'Etalase'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari / Etalase'),
        actions: [
          IconButton(
            tooltip: 'Reset filter',
            icon: const Icon(Icons.tune_rounded),
            onPressed: _resetFilters,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(child: _buildBody(theme)),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(
        child: MonexOrbitLoader(
          size: 60,
          label: 'Memuat etalase',
          message: 'Mengelompokkan komponen menjadi seri produk...',
        ),
      );
    }

    if (_error != null) {
      return MonexEmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Etalase gagal dimuat.',
        message: 'Katalog lokal tidak bisa dibaca. Coba muat ulang.',
        actionLabel: 'Coba lagi',
        onAction: _retry,
      );
    }

    final items = _filteredSeries;

    return CustomScrollView(
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
                TextField(
                  key: const Key('catalog_search'),
                  controller: _search,
                  decoration: InputDecoration(
                    labelText: 'Cari seri produk',
                    hintText: 'cth: RTX 4060, Ryzen 5, B550',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _search.clear();
                              _onQueryChanged('');
                            },
                          ),
                  ),
                  onChanged: _onQueryChanged,
                ),
                const SizedBox(height: MonexSpacing.gridGap),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final category in _categories)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _category == category,
                            onSelected: (_) => _onCategorySelected(category),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: MonexSpacing.sectionGap),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Etalase seri',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '${items.length} seri',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Satu kartu mewakili satu seri. Buka detail untuk spesifikasi dan '
                  'semua varian.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: MonexEmptyState(
              icon: Icons.search_off_rounded,
              title: 'Seri tidak ditemukan.',
              message: 'Coba kata kunci lain atau reset filter.',
              actionLabel: 'Reset filter',
              onAction: _resetFilters,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              MonexSpacing.screenPaddingH,
              0,
              MonexSpacing.screenPaddingH,
              24,
            ),
            sliver: SliverGrid.builder(
              key: const Key('catalog_grid'),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: MonexSpacing.gridGap,
                mainAxisSpacing: MonexSpacing.gridGap,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final series = items[index];
                return ProductSeriesCard(
                  key: ValueKey('series_${series.id}'),
                  series: series,
                  onTap: () => _openDetail(series),
                );
              },
            ),
          ),
      ],
    );
  }
}

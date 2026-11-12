import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/product_series.dart';
import '../state/app_scope.dart';
import '../widgets/product_series_card.dart';
import 'product_detail_screen.dart';

/// Tab Cari/Etalase: satu kartu untuk satu seri produk.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _search = TextEditingController();

  List<ProductSeries>? _series;
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
        _series = series;
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
    setState(() => _category = 'Semua');
  }

  List<ProductSeries> get _filtered {
    final all = _series ?? const <ProductSeries>[];
    final query = _search.text.trim().toLowerCase();
    return all.where((series) {
      if (_category != 'Semua' && series.categoryLabel != _category) {
        return false;
      }
      if (query.isEmpty) return true;
      if (series.name.toLowerCase().contains(query)) return true;
      return series.variants.any(
        (variant) => variant.model.toLowerCase().contains(query),
      );
    }).toList();
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

    final items = _filtered;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        MonexSpacing.screenPaddingH,
        MonexSpacing.screenPaddingV,
        MonexSpacing.screenPaddingH,
        24,
      ),
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
                      setState(() {});
                    },
                  ),
          ),
          onChanged: (_) => setState(() {}),
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
                    onSelected: (_) => setState(() => _category = category),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: MonexSpacing.sectionGap),
        Row(
          children: [
            Expanded(
              child: Text('Etalase seri', style: theme.textTheme.titleLarge),
            ),
            Text('${items.length} seri', style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Satu kartu mewakili satu seri. Buka detail untuk spesifikasi dan '
          'semua varian.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: MonexSpacing.gridGap),
        if (items.isEmpty)
          SizedBox(
            height: 320,
            child: MonexEmptyState(
              icon: Icons.search_off_rounded,
              title: 'Seri tidak ditemukan.',
              message: 'Coba kata kunci lain atau reset filter.',
              actionLabel: 'Reset filter',
              onAction: _resetFilters,
            ),
          )
        else
          GridView.builder(
            key: const Key('catalog_grid'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
      ],
    );
  }
}

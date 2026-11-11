import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/widgets/monex_widgets.dart';

/// Kerangka tab Cari/Etalase.
///
/// Pada fase berikutnya, grid ini diisi satu kartu per seri produk dari
/// `retail_catalog.json`; saat ini yang tampil adalah kategori katalog.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _search = TextEditingController();
  String _category = 'Semua';

  static const _categories = [
    ('Semua', null),
    ('GPU', 'assets/images/gpu.png'),
    ('CPU', 'assets/images/cpu.png'),
    ('Motherboard', 'assets/images/motherboard.png'),
    ('RAM', 'assets/images/ram.png'),
    ('Storage', 'assets/images/storage.png'),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<(String, String?)> get _filtered {
    final query = _search.text.trim().toLowerCase();
    return _categories.where((entry) {
      final matchesCategory = _category == 'Semua' || entry.$1 == _category;
      final matchesQuery =
          query.isEmpty || entry.$1.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari / Etalase'),
        actions: [
          IconButton(
            tooltip: 'Reset filter',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              _search.clear();
              setState(() => _category = 'Semua');
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
          TextField(
            controller: _search,
            decoration: const InputDecoration(
              labelText: 'Cari seri produk',
              hintText: 'cth: RTX 4060, Ryzen 5, B550',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: MonexSpacing.gridGap),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final category in _categories.skip(1))
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category.$1),
                      selected: _category == category.$1,
                      onSelected: (_) =>
                          setState(() => _category = category.$1),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: MonexSpacing.sectionGap),
          Text('Kategori komponen', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Satu kartu akan mewakili satu seri produk pada fase katalog.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: MonexSpacing.gridGap),
          if (items.isEmpty)
            const MonexEmptyState(
              icon: Icons.search_off_rounded,
              title: 'Kategori tidak ditemukan.',
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: MonexSpacing.gridGap,
                mainAxisSpacing: MonexSpacing.gridGap,
                childAspectRatio: 0.92,
              ),
              itemBuilder: (context, index) {
                final entry = items[index];
                return _CategoryCard(
                  title: entry.$1,
                  imageAsset: entry.$2,
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (context) => _CategorySheet(category: entry.$1),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.imageAsset,
    required this.onTap,
  });

  final String title;
  final String? imageAsset;
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
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(MonexSpacing.radiusMd),
              ),
              child: imageAsset == null
                  ? Container(
                      color: MonexColors.surfaceElevated,
                      child: const Center(
                        child: Icon(
                          Icons.grid_view_rounded,
                          size: 42,
                          color: MonexColors.lime,
                        ),
                      ),
                    )
                  : Image.asset(
                      imageAsset!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Lihat seri',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  const _CategorySheet({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Etalase $category',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Kerangka kategori sudah siap. Daftar seri, spesifikasi, dan varian '
            'akan diisi dari retail_catalog.json pada Phase 3.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          MonexPrimaryButton(
            label: 'Mengerti',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

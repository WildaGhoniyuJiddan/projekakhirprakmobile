import 'package:flutter/material.dart';

import '../core/widgets/monex_widgets.dart';

/// Kerangka tab Wishlist.
///
/// CRUD Hive akan dihubungkan pada Phase 2/5; untuk saat ini tampil empty state.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key, this.onOpenCatalog});

  final VoidCallback? onOpenCatalog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          IconButton(
            tooltip: 'Buka etalase',
            icon: const Icon(Icons.storefront_outlined),
            onPressed: onOpenCatalog,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MonexEmptyState(
                icon: Icons.favorite_border_rounded,
                title: 'Wishlist masih kosong.',
              ),
              const SizedBox(height: 16),
              MonexSecondaryButton(
                label: 'Cari produk di etalase',
                icon: Icons.storefront_outlined,
                expanded: false,
                onPressed: onOpenCatalog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

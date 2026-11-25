import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/wishlist_item.dart';
import '../state/app_scope.dart';
import '../widgets/wishlist_form_dialog.dart';
import '../widgets/wishlist_tile.dart';
import 'price_check_screen.dart';

/// Tab Wishlist dengan operasi CRUD penuh di Hive.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key, this.onOpenCatalog});

  final VoidCallback? onOpenCatalog;

  Future<void> _addItem(BuildContext context) async {
    final item = await WishlistFormDialog.show(context);
    if (item == null || !context.mounted) return;

    try {
      await AppScope.of(context).wishlistRepository.add(item);
      if (!context.mounted) return;
      showMonexToast(context, 'Ditambahkan ke wishlist.', isSuccess: true);
    } on Object {
      if (!context.mounted) return;
      showMonexToast(context, 'Gagal menyimpan wishlist.', isError: true);
    }
  }

  Future<void> _editItem(
    BuildContext context,
    int index,
    WishlistItem current,
  ) async {
    final updated = await WishlistFormDialog.show(context, initialItem: current);
    if (updated == null || !context.mounted) return;

    try {
      await AppScope.of(context).wishlistRepository.updateAt(index, updated);
      if (!context.mounted) return;
      showMonexToast(context, 'Wishlist diperbarui.', isSuccess: true);
    } on Object {
      if (!context.mounted) return;
      showMonexToast(context, 'Gagal memperbarui wishlist.', isError: true);
    }
  }

  Future<void> _deleteItem(
    BuildContext context,
    int index,
    WishlistItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus dari wishlist?'),
        content: Text('Item "${item.query}" akan dihapus dari daftar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            key: const Key('wishlist_delete_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: MonexColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await AppScope.of(context).wishlistRepository.deleteAt(index);
      if (!context.mounted) return;
      showMonexToast(context, 'Dihapus dari wishlist.');
    } on Object {
      if (!context.mounted) return;
      showMonexToast(context, 'Gagal menghapus wishlist.', isError: true);
    }
  }

  void _openPriceCheck(BuildContext context, WishlistItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PriceCheckScreen(
          initialQuery: item.query,
          initialPrice: item.targetPrice,
          initialCondition: item.condition,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = AppScope.of(context).wishlistRepository;

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final items = repo.getAll();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Wishlist'),
            actions: [
              IconButton(
                key: const Key('wishlist_add_action'),
                tooltip: 'Tambah wishlist',
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _addItem(context),
              ),
              IconButton(
                tooltip: 'Buka etalase',
                icon: const Icon(Icons.storefront_outlined),
                onPressed: onOpenCatalog,
              ),
              const SizedBox(width: 4),
            ],
          ),
          floatingActionButton: items.isEmpty
              ? null
              : MonexFab(
                  tooltip: 'Tambah wishlist',
                  onPressed: () => _addItem(context),
                ),
          body: items.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const MonexEmptyState(
                          icon: Icons.favorite_border_rounded,
                          title: 'Wishlist masih kosong.',
                          message:
                              'Simpan komponen incaran beserta target harganya.',
                        ),
                        const SizedBox(height: 8),
                        MonexPrimaryButton(
                          key: const Key('wishlist_add_empty'),
                          label: 'Tambah Wishlist',
                          icon: Icons.add_rounded,
                          expanded: false,
                          onPressed: () => _addItem(context),
                        ),
                        const SizedBox(height: 12),
                        MonexSecondaryButton(
                          label: 'Cari produk di etalase',
                          icon: Icons.storefront_outlined,
                          expanded: false,
                          onPressed: onOpenCatalog,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        MonexSpacing.screenPaddingH,
                        MonexSpacing.screenPaddingV,
                        MonexSpacing.screenPaddingH,
                        8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${items.length} item tersimpan',
                            style: theme.textTheme.bodySmall,
                          ),
                          const Spacer(),
                          Text(
                            'Ketuk item untuk cek harga',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          MonexSpacing.screenPaddingH,
                          4,
                          MonexSpacing.screenPaddingH,
                          96,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: MonexSpacing.gridGap),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return WishlistTile(
                            key: ValueKey('wishlist_item_$index'),
                            item: item,
                            onCheckPrice: () => _openPriceCheck(context, item),
                            onEdit: () => _editItem(context, index, item),
                            onDelete: () => _deleteItem(context, index, item),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

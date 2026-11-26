import 'package:flutter/material.dart';

import '../core/theme/app_ui_colors.dart';
import '../core/theme/monex_theme.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/wishlist_item.dart';

/// Kartu item wishlist dengan shortcut cek harga serta aksi ubah dan hapus.
class WishlistTile extends StatelessWidget {
  const WishlistTile({
    super.key,
    required this.item,
    required this.onCheckPrice,
    required this.onEdit,
    required this.onDelete,
  });

  final WishlistItem item;
  final VoidCallback onCheckPrice;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = MonexPalette.of(context);

    return MonexSurfaceCard(
      color: AppUiColors.of(context).wishlistCardBg,
      onTap: onCheckPrice,
      padding: const EdgeInsets.all(MonexSpacing.cardPaddingCompact),
      radius: MonexSpacing.radiusMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: palette.accentSoft,
              borderRadius: BorderRadius.circular(MonexSpacing.radiusSm),
            ),
            child: Icon(
              Icons.favorite_rounded,
              size: 20,
              color: palette.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.query,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Target ${formatRupiah(item.targetPrice)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: palette.surfaceElevated,
                        borderRadius: BorderRadius.circular(
                          MonexSpacing.radiusPill,
                        ),
                      ),
                      child: Text(
                        formatCondition(item.condition),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ubah wishlist',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: 'Hapus wishlist',
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: palette.danger,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

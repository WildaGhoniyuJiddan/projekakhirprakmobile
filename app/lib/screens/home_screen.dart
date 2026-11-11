import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/widgets/monex_widgets.dart';
import '../widgets/app_logo.dart';
import 'price_check_screen.dart';

/// Beranda: pintu masuk fitur utama.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: AppLogo(size: 36, borderRadius: 10),
        ),
        title: const Text('WorthBang'),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => showMonexToast(
              context,
              'Belum ada notifikasi baru.',
            ),
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
            'Mau cek harga apa hari ini?',
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
            onTap: () => _openPage(context, const PriceCheckScreen()),
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
                onTap: () => _openPage(context, const PriceCheckScreen()),
              ),
              _HomeMenuCard(
                icon: Icons.receipt_long_outlined,
                title: 'Riwayat',
                subtitle: 'Cek terakhir akan tampil di sini.',
                onTap: () => showMonexToast(
                  context,
                  'Riwayat akan terisi setelah mesin analisis aktif.',
                ),
              ),
            ],
          ),
        ],
      ),
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

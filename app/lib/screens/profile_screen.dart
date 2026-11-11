import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/widgets/monex_widgets.dart';
import '../state/app_scope.dart';

/// Kerangka tab Profil.
///
/// Login, izin, dan logout dihubungkan pada fase berikutnya.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => showMonexToast(
              context,
              'Pengaturan lanjutan akan tersedia pada fase berikutnya.',
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
          Center(
            child: Column(
              children: [
                ClipOval(
                  child: Image.network(
                    'https://i.pravatar.cc/160?u=worthbang-guest',
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 88,
                      height: 88,
                      color: MonexColors.surfaceElevated,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 44,
                        color: MonexColors.lime,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Tamu', style: theme.textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  'Belum masuk ke akun',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Pengaturan', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          MonexSurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Tema'),
                  subtitle: const Text('Terang, gelap, atau ikuti sistem'),
                  trailing: SizedBox(
                    width: 156,
                    child: ListenableBuilder(
                      listenable: scope.themeController,
                      builder: (context, _) {
                        return MonexSegmentedControl<ThemeMode>(
                          value: scope.themeController.mode,
                          onChanged: scope.themeController.setMode,
                          items: const [
                            MonexSegment(
                              value: ThemeMode.system,
                              label: '',
                              icon: Icons.settings_suggest_outlined,
                            ),
                            MonexSegment(
                              value: ThemeMode.light,
                              label: '',
                              icon: Icons.light_mode_outlined,
                            ),
                            MonexSegment(
                              value: ThemeMode.dark,
                              label: '',
                              icon: Icons.dark_mode_outlined,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.notifications_none_rounded),
                  title: Text('Izin notifikasi'),
                  subtitle: Text('Diminta saat reminder diaktifkan'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.location_on_outlined),
                  title: Text('Izin lokasi'),
                  subtitle: Text('Diminta saat membuka Toko Terdekat'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          MonexSurfaceCard(
            padding: const EdgeInsets.all(MonexSpacing.cardPaddingCompact),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: MonexColors.lime),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'WorthBang Lite 1.0.0 — kerangka aplikasi. '
                    'Fitur analisis, Hive, HTTP, dan LBS menyusul.',
                    style: theme.textTheme.bodySmall,
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

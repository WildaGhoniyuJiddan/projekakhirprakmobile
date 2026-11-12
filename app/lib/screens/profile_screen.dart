import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/widgets/monex_widgets.dart';
import '../state/app_scope.dart';
import 'login_screen.dart';

/// Profil: identitas akun, preferensi tema, dan logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final scope = AppScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Wishlist dan riwayat tetap tersimpan di perangkat ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            key: const Key('logout_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await scope.sessionController.logout();
    } on Object {
      if (!context.mounted) return;
      showMonexToast(context, 'Gagal keluar. Coba lagi.', isError: true);
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = AppScope.of(context);
    final user = scope.sessionController.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
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
      body: SafeArea(
        child: user == null
            ? MonexEmptyState(
                icon: Icons.person_off_outlined,
                title: 'Belum masuk ke akun.',
                message: 'Masuk untuk membuka profil dan wishlist.',
                actionLabel: 'Masuk',
                onAction: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                  (route) => false,
                ),
              )
            : ListView(
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
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipOval(
                              child: Image.network(
                                user.avatarUrl,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                semanticLabel: 'Avatar ${user.name}',
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
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
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: MonexColors.lime,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: MonexColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(user.name, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 2),
                        Text(user.email, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Preferensi', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  MonexSurfaceCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: const Text('Tema'),
                      subtitle: const Text('Terang, gelap, atau ikuti sistem'),
                      trailing: SizedBox(
                        width: 152,
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
                  ),
                  const SizedBox(height: 18),
                  MonexSurfaceCard(
                    padding: const EdgeInsets.all(MonexSpacing.cardPadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.offline_bolt_outlined,
                          size: 18,
                          color: MonexColors.lime,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Akun, wishlist, dan riwayat disimpan lokal di '
                            'perangkat ini. Katalog retail dapat dibuka tanpa '
                            'internet.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  MonexSecondaryButton(
                    key: const Key('profile_logout'),
                    label: 'Keluar dari akun',
                    icon: Icons.logout_rounded,
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
      ),
    );
  }
}

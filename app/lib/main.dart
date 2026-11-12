import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/theme/monex_theme.dart';
import 'core/widgets/monex_widgets.dart';
import 'services/auth_service.dart';
import 'services/history_repository.dart';
import 'services/hive_service.dart';
import 'services/session_preferences.dart';
import 'services/wishlist_repository.dart';
import 'state/app_dependencies.dart';
import 'state/session_controller.dart';
import 'state/theme_controller.dart';
import 'widgets/app_logo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0C0F17),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await HiveService.init();

    final prefs = await SharedPreferences.getInstance();
    final sessionPreferences = SessionPreferences(prefs);

    final themeController = ThemeController(sessionPreferences);
    await themeController.load();

    final sessionController = SessionController(
      AuthService(HiveService.accountsBox, sessionPreferences),
    );
    await sessionController.restore();

    runApp(
      WorthBangApp(
        dependencies: AppDependencies(
          sessionPreferences: sessionPreferences,
          sessionController: sessionController,
          themeController: themeController,
          wishlistRepository: WishlistRepository(HiveService.wishlistBox),
          historyRepository: HistoryRepository(HiveService.historyBox),
        ),
      ),
    );
  } on Object catch (error) {
    runApp(_BootstrapErrorApp(message: error.toString()));
  }
}

/// Layar darurat jika storage gagal dibuka saat bootstrap.
class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MonexTheme.darkTheme,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(MonexSpacing.screenPaddingH),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 72, borderRadius: 20),
                const SizedBox(height: 24),
                Text(
                  'Penyimpanan lokal gagal dibuka.',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                MonexSecondaryButton(
                  label: 'Tutup aplikasi',
                  icon: Icons.close_rounded,
                  onPressed: () => SystemNavigator.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/product_series.dart';
import '../state/app_scope.dart';
import '../widgets/app_logo.dart';
import 'login_screen.dart';
import 'root_screen.dart';

/// Layar pembuka: memanaskan cache katalog lalu mengarahkan ke layar yang
/// sesuai dengan status sesi.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _route();
  }

  Future<void> _route() async {
    final scope = AppScope.of(context);

    // Splash tetap tampil sebentar agar branding terbaca, sambil katalog
    // dimuat di belakang. Kegagalan katalog tidak memblokir masuk aplikasi;
    // layar etalase punya tombol coba lagi sendiri.
    final warmUp = _warmUpCatalog(scope.catalogService.loadSeries);
    await Future.wait([
      warmUp,
      Future<void>.delayed(const Duration(milliseconds: 800)),
    ]);
    if (!mounted) return;

    final destination = scope.sessionController.isLoggedIn
        ? const RootScreen()
        : const LoginScreen();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
  }

  Future<void> _warmUpCatalog(
    Future<List<ProductSeries>> Function() load,
  ) async {
    try {
      await load();
    } on Object {
      // Biarkan etalase menampilkan error + tombol coba lagi.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(MonexSpacing.screenPaddingH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 96, borderRadius: 26),
                const SizedBox(height: 24),
                Text(
                  'WorthBang Lite',
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Cek kelayakan harga komponen PC sebelum membeli.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const MonexOrbitLoader(
                  size: 48,
                  label: 'Menyiapkan etalase',
                  message: 'Memuat katalog retail lokal...',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

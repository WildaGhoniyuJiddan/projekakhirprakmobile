import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/app.dart';
import 'package:worthbang_lite/state/app_dependencies.dart';

import 'support/hive_test_environment.dart';

const _password = 'rahasia123';

Future<void> _pumpApp(WidgetTester tester, AppDependencies dependencies) async {
  await tester.pumpWidget(WorthBangApp(dependencies: dependencies));
  await tester.pumpAndSettle();
}

Future<AppDependencies> _loggedInDependencies(
  WidgetTester tester,
  HiveTestEnvironment env, {
  required String email,
  String name = 'Budi',
}) async {
  late AppDependencies dependencies;
  // Hive menulis ke file nyata; beri kesempatan I/O selesai di luar fake async.
  await tester.runAsync(() async {
    dependencies = await env.dependencies();
    await dependencies.sessionController.register(
      name: name,
      email: email,
      password: _password,
    );
  });
  return dependencies;
}

/// Memberi waktu I/O nyata (Hive/SharedPreferences) lalu menyelesaikan frame.
Future<void> _tapWithIo(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.runAsync(() async {
    await tester.tap(finder);
    await Future<void>.delayed(const Duration(milliseconds: 150));
  });
  await tester.pumpAndSettle();
}

Future<void> _login(
  WidgetTester tester, {
  required String email,
  String password = _password,
}) async {
  await tester.enterText(find.byKey(const Key('login_email')), email);
  await tester.enterText(find.byKey(const Key('login_password')), password);
  await tester.tap(find.byKey(const Key('login_submit')));
  await tester.pumpAndSettle();
}

void main() {
  late HiveTestEnvironment env;

  setUpAll(() async {
    env = await HiveTestEnvironment.create();
  });

  tearDownAll(() async {
    await env.dispose();
  });

  testWidgets('splash mengarahkan tamu ke layar login', (tester) async {
    final dependencies = await env.dependencies();

    await _pumpApp(tester, dependencies);

    expect(find.text('Masuk ke WorthBang'), findsOneWidget);
    expect(find.byKey(const Key('login_register_link')), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });

  testWidgets('register masuk ke root, logout kembali ke login', (
    tester,
  ) async {
    final dependencies = await env.dependencies();
    const email = 'alur.auth@worthbang.test';

    await _pumpApp(tester, dependencies);
    await tester.tap(find.byKey(const Key('login_register_link')));
    await tester.pumpAndSettle();

    expect(find.text('Buat Akun'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('register_name')), 'Rina');
    await tester.enterText(find.byKey(const Key('register_email')), email);
    await tester.enterText(
      find.byKey(const Key('register_password')),
      _password,
    );
    await tester.enterText(
      find.byKey(const Key('register_confirm')),
      _password,
    );
    await tester.ensureVisible(find.byKey(const Key('register_submit')));
    await _tapWithIo(tester, find.byKey(const Key('register_submit')));

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Halo, Rina!'), findsOneWidget);

    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    expect(find.text('Preferensi'), findsOneWidget);
    expect(find.text('Rina'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('profile_logout')));
    await tester.tap(find.byKey(const Key('profile_logout')));
    await tester.pumpAndSettle();
    expect(find.text('Keluar dari akun?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('logout_confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Masuk ke WorthBang'), findsOneWidget);

    await _login(tester, email: email);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Halo, Rina!'), findsOneWidget);
  });

  testWidgets('login menolak kata sandi salah', (tester) async {
    final dependencies = await _loggedInDependencies(
      tester,
      env,
      email: 'salah.password@worthbang.test',
    );
    // dependencies dibuat dalam keadaan sudah login; logout dulu agar
    // layar login yang diuji.
    await dependencies.sessionController.logout();

    await _pumpApp(tester, dependencies);
    await _login(
      tester,
      email: 'salah.password@worthbang.test',
      password: 'kata-sandi-salah',
    );

    expect(find.text('Email atau kata sandi salah.'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });

  testWidgets('shell 4 tab dan etalase membuka detail produk', (tester) async {
    final dependencies = await _loggedInDependencies(
      tester,
      env,
      email: 'alur.etalase@worthbang.test',
      name: 'Sari',
    );

    await _pumpApp(tester, dependencies);

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Cari'), findsWidgets);
    expect(find.text('Wishlist'), findsWidgets);
    expect(find.text('Profil'), findsWidgets);

    await tester.tap(find.text('Cari').last);
    await tester.pumpAndSettle();
    expect(find.text('Cari / Etalase'), findsOneWidget);
    expect(find.byKey(const Key('catalog_grid')), findsOneWidget);
    expect(find.text('RTX 4060'), findsWidgets);

    await tester.enterText(find.byKey(const Key('catalog_search')), 'RTX 4060');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('series_gpu:RTX 4060')));
    await tester.pumpAndSettle();

    expect(find.text('Spesifikasi'), findsOneWidget);
    expect(find.text('Varian & harga'), findsOneWidget);
    expect(find.text('3 produk'), findsOneWidget);
    expect(find.text('Cek Harga RTX 4060'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('detail_price_check')));
    await tester.tap(find.byKey(const Key('detail_price_check')));
    await tester.pumpAndSettle();
    expect(find.text('Cek Harga'), findsOneWidget);
    expect(find.text('RTX 4060'), findsWidgets);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Varian & harga'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Cari / Etalase'), findsOneWidget);

    await tester.tap(find.text('Wishlist').last);
    await tester.pumpAndSettle();
    expect(find.text('Wishlist masih kosong.'), findsOneWidget);

    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    expect(find.text('Sari'), findsOneWidget);
  });

  testWidgets('form cek harga memvalidasi input kosong', (tester) async {
    final dependencies = await _loggedInDependencies(
      tester,
      env,
      email: 'alur.harga@worthbang.test',
    );

    await _pumpApp(tester, dependencies);
    await tester.tap(find.text('Cek Harga').first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cek Kelayakan'));
    await tester.tap(find.text('Cek Kelayakan'));
    await tester.pumpAndSettle();

    expect(find.text('Nama produk minimal 2 karakter.'), findsOneWidget);
    expect(find.text('Masukkan harga yang valid.'), findsOneWidget);
  });
}

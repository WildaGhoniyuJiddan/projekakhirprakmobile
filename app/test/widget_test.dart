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

/// Mengetuk tombol di dalam dialog yang memicu I/O Hive setelah dialog ditutup.
Future<void> _tapDialogWithIo(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 150)),
  );
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

  setUp(() async {
    await env.clearBoxes();
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

  testWidgets('cek harga menampilkan hasil, menyimpan riwayat, dan simpan ke wishlist', (
    tester,
  ) async {
    final dependencies = await _loggedInDependencies(
      tester,
      env,
      email: 'alur.result@worthbang.test',
    );

    await _pumpApp(tester, dependencies);
    await tester.tap(find.text('Cek Harga').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('price_check_query')),
      'RTX 4060',
    );
    await tester.enterText(
      find.byKey(const Key('price_check_price')),
      '3800000',
    );
    await _tapWithIo(tester, find.byKey(const Key('price_check_submit')));

    expect(find.text('Hasil Analisis'), findsOneWidget);
    expect(find.text('Worth It'), findsOneWidget);
    expect(find.text('Ringkasan harga'), findsOneWidget);
    expect(dependencies.historyRepository.length, 1);

    await tester.ensureVisible(find.byKey(const Key('result_save_wishlist')));
    await tester.tap(find.byKey(const Key('result_save_wishlist')));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Wishlist'), findsOneWidget);

    await _tapDialogWithIo(tester, find.byKey(const Key('wishlist_form_submit')));
    expect(dependencies.wishlistRepository.length, 1);

    // Tunggu toast menghilang sebelum mengetuk tombol di bagian bawah layar.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('result_done')));
    await tester.tap(find.byKey(const Key('result_done')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Riwayat tampil di Beranda dan item tampil di Wishlist.
    await tester.scrollUntilVisible(
      find.text('Riwayat cek terbaru'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Riwayat cek terbaru'), findsOneWidget);
    expect(find.text('RTX 4060'), findsWidgets);

    await tester.tap(find.text('Wishlist').last);
    await tester.pumpAndSettle();
    expect(find.text('1 item tersimpan'), findsOneWidget);
    expect(find.text('RTX 4060'), findsOneWidget);
  });

  testWidgets('wishlist mendukung create, update, cek harga, dan delete di Hive', (
    tester,
  ) async {
    final dependencies = await _loggedInDependencies(
      tester,
      env,
      email: 'alur.wishlist@worthbang.test',
    );

    await _pumpApp(tester, dependencies);
    await tester.tap(find.text('Wishlist').last);
    await tester.pumpAndSettle();
    expect(find.text('Wishlist masih kosong.'), findsOneWidget);

    // Create
    await tester.tap(find.byKey(const Key('wishlist_add_empty')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('wishlist_form_query')),
      'Ryzen 5 5600',
    );
    await tester.enterText(
      find.byKey(const Key('wishlist_form_price')),
      '1850000',
    );
    await _tapDialogWithIo(tester, find.byKey(const Key('wishlist_form_submit')));

    expect(find.text('1 item tersimpan'), findsOneWidget);
    expect(find.text('Ryzen 5 5600'), findsOneWidget);

    // Update
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Ubah Wishlist'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('wishlist_form_price')),
      '1700000',
    );
    await _tapDialogWithIo(tester, find.byKey(const Key('wishlist_form_submit')));

    expect(dependencies.wishlistRepository.getAt(0)!.targetPrice, 1700000);

    // Shortcut ke Cek Harga
    await tester.tap(find.byKey(const ValueKey('wishlist_item_0')));
    await tester.pumpAndSettle();
    expect(find.text('Cek Harga'), findsOneWidget);
    expect(find.text('Ryzen 5 5600'), findsWidgets);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Delete
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Hapus dari wishlist?'), findsOneWidget);
    await _tapDialogWithIo(
      tester,
      find.byKey(const Key('wishlist_delete_confirm')),
    );

    expect(dependencies.wishlistRepository.length, 0);
    expect(find.text('Wishlist masih kosong.'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worthbang_lite/app.dart';
import 'package:worthbang_lite/state/theme_controller.dart';

Future<ThemeController> _controller() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final controller = ThemeController(prefs);
  await controller.load();
  return controller;
}

void main() {
  testWidgets('shell menampilkan 4 tab dan berpindah tab', (tester) async {
    final controller = await _controller();

    await tester.pumpWidget(WorthBangApp(themeController: controller));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Cari'), findsWidgets);
    expect(find.text('Wishlist'), findsWidgets);
    expect(find.text('Profil'), findsWidgets);

    await tester.tap(find.text('Cari').last);
    await tester.pumpAndSettle();
    expect(find.text('Cari / Etalase'), findsOneWidget);

    await tester.tap(find.text('Wishlist').last);
    await tester.pumpAndSettle();
    expect(find.text('Wishlist masih kosong.'), findsOneWidget);

    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    expect(find.text('Pengaturan'), findsOneWidget);
  });

  testWidgets('form cek harga memvalidasi input kosong', (tester) async {
    final controller = await _controller();

    await tester.pumpWidget(WorthBangApp(themeController: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cek Harga').first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cek Kelayakan'));
    await tester.tap(find.text('Cek Kelayakan'));
    await tester.pumpAndSettle();

    expect(find.text('Nama produk minimal 2 karakter.'), findsOneWidget);
    expect(find.text('Masukkan harga yang valid.'), findsOneWidget);
  });
}

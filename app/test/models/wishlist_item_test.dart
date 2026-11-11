import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:worthbang_lite/models/wishlist_item.dart';

void main() {
  group('WishlistItem', () {
    test('generative constructor merapikan query', () {
      final item = WishlistItem(query: '  RTX 4060  ', targetPrice: 4500000);
      expect(item.query, 'RTX 4060');
      expect(item.targetPrice, 4500000);
      expect(item.condition, 'baru');
    });

    test('redirecting constructor .empty memberi template', () {
      final item = WishlistItem.empty();
      expect(item.query, 'Produk baru');
      expect(item.targetPrice, 1000000);
    });

    test('fromMap/toMap round-trip', () {
      final item = WishlistItem.fromMap({
        'query': 'Ryzen 5 5600',
        'target_price': 1800000,
        'condition': 'bekas',
      });
      expect(item.query, 'Ryzen 5 5600');
      expect(item.targetPrice, 1800000);
      expect(item.condition, 'bekas');
      expect(item.toMap(), {
        'query': 'Ryzen 5 5600',
        'target_price': 1800000,
        'condition': 'bekas',
      });
    });

    test('setter memvalidasi perubahan state', () {
      final item = WishlistItem.empty();
      item.query = 'RX 7600';
      item.targetPrice = 3500000;
      item.condition = 'any';

      expect(item.query, 'RX 7600');
      expect(item.targetPrice, 3500000);
      expect(item.condition, 'any');
      expect(() => item.query = 'X', throwsArgumentError);
      expect(() => item.targetPrice = 0, throwsArgumentError);
      expect(() => item.condition = 'rusak', throwsArgumentError);
    });

    test('copyWith mempertahankan nilai yang tidak diubah', () {
      final item = WishlistItem.empty();
      final copy = item.copyWith(targetPrice: 5000000);
      expect(copy.query, item.query);
      expect(copy.targetPrice, 5000000);
      expect(copy.condition, item.condition);
    });
  });

  group('WishlistItemAdapter + Hive', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('worthbang_hive_');
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(WishlistItemAdapter());
      }
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test('menyimpan dan membaca kembali objek dari Box', () async {
      final box = await Hive.openBox<WishlistItem>('wishlist_adapter_test');
      await box.add(WishlistItem(query: 'RTX 4060', targetPrice: 4500000));

      final stored = box.getAt(0);
      expect(stored, isNotNull);
      expect(stored!.query, 'RTX 4060');
      expect(stored.targetPrice, 4500000);
      expect(stored.condition, 'baru');

      await box.close();
    });
  });
}

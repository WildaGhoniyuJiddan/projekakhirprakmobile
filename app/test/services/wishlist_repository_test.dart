import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:worthbang_lite/models/wishlist_item.dart';
import 'package:worthbang_lite/services/wishlist_repository.dart';

import '../support/hive_test_environment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HiveTestEnvironment env;
  late WishlistRepository repo;

  setUpAll(() async {
    env = await HiveTestEnvironment.create();
  });

  tearDownAll(() async {
    await env.dispose();
  });

  setUp(() async {
    await env.wishlistBox.clear();
    repo = WishlistRepository(env.wishlistBox);
  });

  group('WishlistRepository CRUD', () {
    test('add lalu getAll membaca item', () async {
      await repo.add(WishlistItem(query: 'RTX 4060', targetPrice: 4500000));
      await repo.add(
        WishlistItem(
          query: 'Ryzen 5 5600',
          targetPrice: 1800000,
          condition: 'bekas',
        ),
      );

      expect(repo.length, 2);
      final items = repo.getAll();
      expect(items, hasLength(2));
      expect(items.first.query, 'RTX 4060');
      expect(items.last.condition, 'bekas');
    });

    test('getAt membaca item berdasarkan posisi Hive', () async {
      final key = await repo.add(
        WishlistItem(query: 'RTX 4060', targetPrice: 4500000),
      );

      final item = repo.getAt(key);
      expect(item, isNotNull);
      expect(item!.query, 'RTX 4060');
      expect(item.key, key);
    });

    test('updateAt mengubah target harga tanpa mengubah query', () async {
      final key = await repo.add(
        WishlistItem(query: 'RTX 4060', targetPrice: 4500000),
      );

      await repo.updateAt(
        key,
        WishlistItem(query: 'RTX 4060', targetPrice: 4000000),
      );

      final updated = repo.getAt(key);
      expect(updated!.targetPrice, 4000000);
      expect(updated.query, 'RTX 4060');
    });

    test('deleteAt menghapus item pada posisi yang dipilih', () async {
      await repo.add(WishlistItem(query: 'RTX 4060', targetPrice: 4500000));
      await repo.add(WishlistItem(query: 'RX 7600', targetPrice: 3500000));

      await repo.deleteAt(0);

      expect(repo.length, 1);
      expect(repo.getAt(0)!.query, 'RX 7600');
      expect(repo.getAt(1), isNull);
    });

    test('containsQuery mencocokkan nama tanpa peduli kapital', () async {
      await repo.add(WishlistItem(query: 'RTX 4060', targetPrice: 4500000));

      expect(repo.containsQuery('  rtx 4060 '), isTrue);
      expect(repo.containsQuery('RX 7600'), isFalse);
    });

    test('data bertahan setelah box ditutup dan dibuka kembali', () async {
      final box = await Hive.openBox<WishlistItem>('wishlist_persist_test');
      await box.clear();
      await WishlistRepository(box)
          .add(WishlistItem(query: 'RTX 4060', targetPrice: 4500000));
      await box.close();

      final reopened = await Hive.openBox<WishlistItem>(
        'wishlist_persist_test',
      );
      final items = WishlistRepository(reopened).getAll();

      expect(items, hasLength(1));
      expect(items.single.query, 'RTX 4060');
      expect(items.single.targetPrice, 4500000);

      await reopened.clear();
      await reopened.close();
    });
  });
}

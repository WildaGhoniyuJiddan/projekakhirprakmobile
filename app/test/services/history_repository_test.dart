import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/models/price_analysis.dart';
import 'package:worthbang_lite/models/price_check_request.dart';
import 'package:worthbang_lite/models/price_verdict.dart';
import 'package:worthbang_lite/services/history_repository.dart';

import '../support/hive_test_environment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HiveTestEnvironment env;
  late HistoryRepository repo;

  PriceAnalysis analysis(String query, int price, PriceVerdict verdict) {
    return PriceAnalysis(
      request: PriceCheckRequest(query: query, price: price),
      referencePrice: price,
      score: 80,
      verdict: verdict,
      fairPriceLow: price,
      fairPriceHigh: price,
    );
  }

  setUpAll(() async {
    env = await HiveTestEnvironment.create();
  });

  tearDownAll(() async {
    await env.dispose();
  });

  setUp(() async {
    await env.historyBox.clear();
    repo = HistoryRepository(env.historyBox);
  });

  group('HistoryRepository', () {
    test('add lalu getAll mengembalikan riwayat terbaru lebih dulu', () async {
      await repo.add(analysis('RTX 4060', 4500000, const FairVerdict()));
      await repo.add(analysis('RX 7600', 3500000, const WorthItVerdict()));

      final records = repo.getAll();
      expect(records, hasLength(2));
      expect(records.first.analysis.request.query, 'RX 7600');
      expect(records.first.analysis.verdict, isA<WorthItVerdict>());
      expect(records.last.analysis.request.query, 'RTX 4060');
    });

    test('recent membatasi jumlah riwayat', () async {
      for (var i = 0; i < 5; i++) {
        await repo.add(analysis('Produk $i', 1000000 + i, const FairVerdict()));
      }

      final recent = repo.recent(limit: 3);
      expect(recent, hasLength(3));
      expect(recent.first.analysis.request.query, 'Produk 4');
      expect(recent.last.analysis.request.query, 'Produk 2');
    });

    test('deleteAt menghapus riwayat berdasarkan key', () async {
      final key = await repo.add(
        analysis('RTX 4060', 4500000, const FairVerdict()),
      );
      await repo.add(analysis('RX 7600', 3500000, const WorthItVerdict()));

      await repo.deleteAt(key);

      expect(repo.length, 1);
      expect(repo.getAll().single.analysis.request.query, 'RX 7600');
    });

    test('data korup dilewati tanpa menjatuhkan getAll', () async {
      await env.historyBox.put('bukan-angka', 'data lama');
      await env.historyBox.put(99, {'query': 123});
      await repo.add(analysis('RTX 4060', 4500000, const FairVerdict()));

      final records = repo.getAll();
      expect(records, hasLength(1));
      expect(records.single.analysis.request.query, 'RTX 4060');
    });
  });
}

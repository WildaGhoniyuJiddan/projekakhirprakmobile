import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/models/price_analysis.dart';
import 'package:worthbang_lite/models/price_check_request.dart';
import 'package:worthbang_lite/models/price_verdict.dart';

void main() {
  group('PriceAnalysis', () {
    PriceAnalysis sample() => PriceAnalysis(
      request: PriceCheckRequest(query: 'RTX 4060', price: 4500000),
      referencePrice: 4600000,
      score: 82.5,
      verdict: const FairVerdict(),
      comparisons: [
        const PriceComparison(
          title: 'RTX 4060 Dual',
          price: 4550000,
          source: 'retail',
          similarity: 0.92,
          condition: 'baru',
        ),
      ],
      fairPriceLow: 4200000,
      fairPriceHigh: 4900000,
    );

    test('toJson/fromJson round-trip mempertahankan data', () {
      final original = sample();
      final restored = PriceAnalysis.fromJson(original.toJson());

      expect(restored.request.query, 'RTX 4060');
      expect(restored.request.price, 4500000);
      expect(restored.referencePrice, 4600000);
      expect(restored.score, 82.5);
      expect(restored.verdict, isA<FairVerdict>());
      expect(restored.comparisons, hasLength(1));
      expect(restored.comparisons.first.price, 4550000);
      expect(restored.fairPriceLow, 4200000);
      expect(restored.fairPriceHigh, 4900000);
    });

    test('redirecting constructor .empty memberi state aman', () {
      final empty = PriceAnalysis.empty();
      expect(empty.request.query, 'RTX 4060');
      expect(empty.referencePrice, 0);
      expect(empty.score, 0);
      expect(empty.verdict, isA<LimitedDataVerdict>());
      expect(empty.comparisons, isEmpty);
    });

    test('fromJson menangani data korup tanpa crash', () {
      final restored = PriceAnalysis.fromJson({
        'query': '',
        'price': 0,
        'condition': 'tidak-valid',
        'score': 999,
        'verdict_key': 'kemahalan',
      });
      expect(restored.request.query, 'Produk');
      expect(restored.request.price, 1);
      expect(restored.request.condition, 'baru');
      expect(restored.score, 100);
      expect(restored.verdict, isA<OverpricedVerdict>());
    });

    test('skor selalu di-clamp 0..100', () {
      final low = PriceAnalysis(
        request: PriceCheckRequest(query: 'RTX 4060', price: 1),
        referencePrice: 0,
        score: -20,
        verdict: const WorthItVerdict(),
        fairPriceLow: 0,
        fairPriceHigh: 0,
      );
      expect(low.score, 0);
    });
  });
}

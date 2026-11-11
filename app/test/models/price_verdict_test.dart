import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/models/price_verdict.dart';

void main() {
  group('PriceVerdict', () {
    test('setiap subclass punya label, key, dan warna berbeda', () {
      const worth = WorthItVerdict();
      const fair = FairVerdict();
      const over = OverpricedVerdict();
      const limited = LimitedDataVerdict();

      expect(worth.label, 'Worth It');
      expect(fair.label, 'Wajar');
      expect(over.label, 'Kemahalan');
      expect(limited.label, 'Data Terbatas');

      expect(worth.key, 'worth_it');
      expect(fair.key, 'fair');
      expect(over.key, 'overpriced');
      expect(limited.key, 'limited');

      expect(worth.color, isNot(fair.color));
      expect(fair.color, isNot(over.color));
    });

    test('polymorphism: advice dan emphasis di-override', () {
      const over = OverpricedVerdict();
      const fair = FairVerdict();
      expect(over.emphasis, greaterThan(fair.emphasis));
      expect(over.advice, contains('negosiasi'));
    });

    test('fromKey mengembalikan subclass yang tepat', () {
      expect(PriceVerdict.fromKey('worth_it'), isA<WorthItVerdict>());
      expect(PriceVerdict.fromKey('wajar'), isA<FairVerdict>());
      expect(PriceVerdict.fromKey('kemahalan'), isA<OverpricedVerdict>());
      expect(PriceVerdict.fromKey('data terbatas'), isA<LimitedDataVerdict>());
      expect(PriceVerdict.fromKey(null), isA<FairVerdict>());
    });
  });
}

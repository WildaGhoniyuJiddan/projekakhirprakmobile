import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/models/currency_rate.dart';

void main() {
  group('CurrencyRate', () {
    test('fromJson membaca kode dan rate', () {
      final rate = CurrencyRate.fromJson({'code': 'usd', 'rate': 0.000062});
      expect(rate.code, 'USD');
      expect(rate.rate, 0.000062);
    });

    test('convertFromIdr mengalikan nominal', () {
      const rate = CurrencyRate(code: 'USD', rate: 0.000062);
      expect(rate.convertFromIdr(4500000), closeTo(279, 0.001));
    });

    test('toJson mengembalikan bentuk yang sama', () {
      const rate = CurrencyRate(code: 'SGD', rate: 0.000083);
      expect(rate.toJson(), {'code': 'SGD', 'rate': 0.000083});
    });
  });
}

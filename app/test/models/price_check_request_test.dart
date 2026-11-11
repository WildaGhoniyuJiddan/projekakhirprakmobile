import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/models/price_check_request.dart';

void main() {
  group('PriceCheckRequest', () {
    test('generative constructor memvalidasi dan merapikan query', () {
      final request = PriceCheckRequest(query: '  RTX 4060  ', price: 4500000);
      expect(request.query, 'RTX 4060');
      expect(request.price, 4500000);
      expect(request.condition, 'baru');
    });

    test('redirecting constructor .empty memberi data awal form', () {
      final request = PriceCheckRequest.empty();
      expect(request.query, 'RTX 4060');
      expect(request.price, 4500000);
      expect(request.condition, 'baru');
    });

    test('named constructor .fromJson membaca map', () {
      final request = PriceCheckRequest.fromJson({
        'query': 'Ryzen 5 5600',
        'price': 1800000,
        'condition': 'bekas',
      });
      expect(request.query, 'Ryzen 5 5600');
      expect(request.price, 1800000);
      expect(request.condition, 'bekas');
    });

    test('query < 2 karakter ditolak', () {
      expect(
        () => PriceCheckRequest(query: 'A', price: 1000),
        throwsArgumentError,
      );
    });

    test('harga <= 0 ditolak', () {
      expect(
        () => PriceCheckRequest(query: 'RTX 4060', price: 0),
        throwsArgumentError,
      );
    });

    test('kondisi tidak valid ditolak', () {
      expect(
        () => PriceCheckRequest(
          query: 'RTX 4060',
          price: 1000,
          condition: 'rusak',
        ),
        throwsArgumentError,
      );
    });

    test('setter memvalidasi perubahan state', () {
      final request = PriceCheckRequest.empty();
      request.query = '  RX 7600  ';
      request.price = 3500000;
      request.condition = 'bekas';

      expect(request.query, 'RX 7600');
      expect(request.price, 3500000);
      expect(request.condition, 'bekas');

      expect(() => request.query = 'X', throwsArgumentError);
      expect(() => request.price = -1, throwsArgumentError);
      expect(() => request.condition = 'baru sekali', throwsArgumentError);
    });

    test('toJson mengembalikan bentuk kontrak', () {
      final json = PriceCheckRequest(
        query: 'RTX 4060',
        price: 4500000,
      ).toJson();
      expect(json, {
        'query': 'RTX 4060',
        'price': 4500000,
        'condition': 'baru',
      });
    });
  });
}

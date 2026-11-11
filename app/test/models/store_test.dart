import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/models/store.dart';

void main() {
  group('Store', () {
    final json = {
      'id': 1,
      'name': 'Enter Komputer',
      'address': 'Mangga Dua',
      'city': 'Jakarta',
      'lat': -6.1375,
      'lng': 106.8245,
      'prices': {'RTX 4060': 4750000, 'Ryzen 5 5600': 1890000},
    };

    test('fromJson membaca koordinat dan harga', () {
      final store = Store.fromJson(json);
      expect(store.id, 1);
      expect(store.name, 'Enter Komputer');
      expect(store.lat, -6.1375);
      expect(store.prices['RTX 4060'], 4750000);
    });

    test('copyWithDistance mempertahankan data lain', () {
      final store = Store.fromJson(json).copyWithDistance(2.4);
      expect(store.distanceKm, 2.4);
      expect(store.name, 'Enter Komputer');
      expect(store.prices['Ryzen 5 5600'], 1890000);
    });

    test('priceFor mencari harga case-insensitive', () {
      final store = Store.fromJson(json);
      expect(store.priceFor('rtx 4060'), 4750000);
      expect(store.priceFor('tidak ada'), isNull);
    });
  });
}

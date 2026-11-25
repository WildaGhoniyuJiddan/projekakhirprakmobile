import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/services/store_service.dart';

import '../support/json_asset_bundle.dart';
import '../support/sample_stores.dart';

void main() {
  group('StoreService.distanceKm', () {
    test('menghitung jarak great-circle dalam kilometer', () {
      final distance = StoreService.distanceKm(0, 0, 0, 1);
      expect(distance, closeTo(111.19, 0.05));
    });

    test('koordinat sama menghasilkan jarak nol', () {
      expect(StoreService.distanceKm(-6.2, 106.8, -6.2, 106.8), 0);
    });
  });

  group('StoreService.nearby', () {
    late StoreService service;

    setUp(() {
      service = StoreService(JsonAssetBundle(sampleStoresJson));
    });

    test('tanpa query hanya mengambil toko dalam radius', () async {
      final stores = await service.nearby(lat: -6.2088, lng: 106.8456);

      expect(stores.map((store) => store.name), ['Toko Dekat', 'Toko Sedang']);
      expect(stores.first.distanceKm, lessThan(stores.last.distanceKm));
      expect(stores.first.distanceKm, lessThan(1));
      expect(stores.last.distanceKm, closeTo(2.4, 0.3));
    });

    test(
      'query produk menampilkan semua toko yang menjual, terurut jarak',
      () async {
        final stores = await service.nearby(
          lat: -6.2088,
          lng: 106.8456,
          query: 'RTX 4060',
        );

        expect(stores, hasLength(3));
        expect(stores.first.name, 'Toko Dekat');
        expect(stores.last.name, 'Toko Jauh');
        expect(stores.last.distanceKm, greaterThan(100));
      },
    );

    test('query nama toko mencocokkan tanpa peduli kapital', () async {
      final stores = await service.nearby(
        lat: -6.2088,
        lng: 106.8456,
        query: 'toko SEDANG',
      );

      expect(stores, hasLength(1));
      expect(stores.single.name, 'Toko Sedang');
    });

    test('query kota mencocokkan toko di luar radius', () async {
      final stores = await service.nearby(
        lat: -6.2088,
        lng: 106.8456,
        query: 'yogyakarta',
      );

      expect(stores, hasLength(1));
      expect(stores.single.city, 'Yogyakarta');
    });

    test('query tanpa hasil mengembalikan list kosong', () async {
      final stores = await service.nearby(
        lat: -6.2088,
        lng: 106.8456,
        query: 'komponen yang tidak ada',
      );

      expect(stores, isEmpty);
    });
  });

  group('StoreService.loadStores', () {
    test('melewati baris rusak dan koordinat nol', () async {
      const json = '''
      [
        {"id": 1, "name": "Valid", "address": "Jl. A", "city": "Jakarta",
         "lat": -6.2, "lng": 106.8, "prices": {"RTX 4060": 4500000}},
        "bukan object",
        {"id": 2, "name": "Tanpa Koordinat", "address": "Jl. B", "city": "Jakarta",
         "lat": 0, "lng": 0}
      ]
      ''';
      final service = StoreService(JsonAssetBundle(json));

      final stores = await service.loadStores();

      expect(stores, hasLength(1));
      expect(stores.single.name, 'Valid');
      expect(stores.single.priceFor('rtx 4060'), 4500000);
    });

    test('meng-cache hasil load', () async {
      final service = StoreService(JsonAssetBundle(sampleStoresJson));

      final first = await service.loadStores();
      final second = await service.loadStores();

      expect(identical(first, second), isTrue);
    });

    test('menolak format bukan list', () async {
      final service = StoreService(JsonAssetBundle('{"id": 1}'));

      expect(service.loadStores(), throwsFormatException);
    });

    test('menolak data kosong', () async {
      final service = StoreService(JsonAssetBundle('[]'));

      expect(service.loadStores(), throwsFormatException);
    });
  });
}

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/models/catalog_item.dart';
import 'package:worthbang_lite/services/catalog_service.dart';

import '../support/json_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String sampleCatalog() => jsonEncode({
    'generated_at': '2026-01-01T00:00:00Z',
    'gpu': [
      {'model': 'ASUS RTX 4060 8GB GDDR6 - Dual', 'price': 4800000},
      {'model': 'MSI RTX 4060 8GB GDDR6 - Ventus', 'price': 4500000},
      {'model': 'ASUS RTX 4060 Ti 8GB GDDR6 - Dual', 'price': 7000000},
      {'model': 'ASRock RX 7600 8GB GDDR6', 'price': 3500000},
      {'model': '', 'price': 0},
    ],
    'cpu': [
      {'model': 'AMD Ryzen 5 5600 3.5GHz 6 Core AM4', 'price': 2000000},
      {'model': 'AMD Ryzen 5 5600G 3.9GHz 6 Core AM4', 'price': 2300000},
    ],
    'motherboard': [
      {'model': 'MSI PRO B550M-VC WIFI AM4', 'price': 1400000},
      {'model': 'ASUS TUF B550M-PLUS AM4', 'price': 1600000},
    ],
    'ram': [
      {'model': 'ADATA DDR4 16GB 3200MHz', 'price': 700000},
      {'model': 'ADATA DDR5 32GB 5600MHz', 'price': 1800000},
    ],
    'storage': [
      {'model': 'ADATA Legend 710 1TB NVMe M.2', 'price': 900000},
      {'model': 'Seagate Barracuda 1TB HDD SATA', 'price': 600000},
    ],
    'keyboard': [
      {'model': 'Mechanical Keyboard', 'price': 500000},
    ],
  });

  group('CatalogService.loadItems', () {
    test('membaca item valid dan melewati baris rusak', () async {
      final service = CatalogService(JsonAssetBundle(sampleCatalog()));

      final items = await service.loadItems();

      expect(items, hasLength(12));
      expect(items.whereType<GpuItem>(), hasLength(4));
      expect(items.whereType<CpuItem>(), hasLength(2));
      expect(items.whereType<MotherboardItem>(), hasLength(2));
      expect(items.whereType<RamItem>(), hasLength(2));
      expect(items.whereType<StorageItem>(), hasLength(2));
    });

    test('meng-cache hasil load', () async {
      final service = CatalogService(JsonAssetBundle(sampleCatalog()));

      final first = await service.loadItems();
      final second = await service.loadItems();

      expect(identical(first, second), isTrue);
    });

    test('menolak katalog kosong dan format bukan object', () async {
      final empty = CatalogService(JsonAssetBundle('{}'));
      await expectLater(empty.loadItems(), throwsFormatException);

      final array = CatalogService(JsonAssetBundle('[]'));
      await expectLater(array.loadItems(), throwsFormatException);
    });
  });

  group('CatalogService.loadSeries', () {
    test('mengelompokkan varian menjadi satu seri', () async {
      final service = CatalogService(JsonAssetBundle(sampleCatalog()));

      final series = await service.loadSeries();
      final rtx = series.firstWhere((item) => item.name == 'RTX 4060');

      expect(rtx.id, 'gpu:RTX 4060');
      expect(rtx.category, 'gpu');
      expect(rtx.categoryLabel, 'GPU');
      expect(rtx.variantCount, 2);
      expect(rtx.minPrice, 4500000);
      expect(rtx.maxPrice, 4800000);
      expect(rtx.imageAsset, 'assets/images/gpu.png');
      expect(rtx.specs['VRAM'], '8GB');
      expect(rtx.specs['Memori'], 'GDDR6');
    });

    test('memisahkan RTX 4060 dan RTX 4060 Ti', () async {
      final service = CatalogService(JsonAssetBundle(sampleCatalog()));

      final series = await service.loadSeries();
      final names = series.map((item) => item.name).toList();

      expect(names, contains('RTX 4060'));
      expect(names, contains('RTX 4060 Ti'));
    });

    test('menampilkan nama seri yang ramah untuk tiap kategori', () async {
      final service = CatalogService(JsonAssetBundle(sampleCatalog()));

      final names = (await service.loadSeries())
          .map((item) => item.name)
          .toSet();

      expect(names, contains('Ryzen 5 5600'));
      expect(names, contains('Ryzen 5 5600G'));
      expect(names, contains('B550'));
      expect(names, contains('DDR4 16GB 3200MHz'));
      expect(names, contains('NVMe 1TB'));
      expect(names, contains('SATA 1TB'));
    });

    test('meng-cache hasil grouping', () async {
      final service = CatalogService(JsonAssetBundle(sampleCatalog()));

      final first = await service.loadSeries();
      final second = await service.loadSeries();

      expect(identical(first, second), isTrue);
    });

    test('aset katalog nyata dapat dimuat dan dikelompokkan', () async {
      final service = CatalogService(rootBundle);

      final items = await service.loadItems();
      final series = await service.loadSeries();

      expect(items.length, greaterThan(2000));
      expect(series.length, greaterThan(100));
      expect(
        series.map((item) => item.category).toSet(),
        containsAll(['gpu', 'cpu', 'motherboard', 'ram', 'storage']),
      );

      final rtx = series.where((item) => item.name == 'RTX 4060').toList();
      expect(rtx, isNotEmpty);
      expect(rtx.first.variantCount, greaterThan(3));
    });
  });
}

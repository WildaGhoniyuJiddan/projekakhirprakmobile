import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/models/price_check_request.dart';
import 'package:worthbang_lite/models/price_verdict.dart';
import 'package:worthbang_lite/services/catalog_service.dart';
import 'package:worthbang_lite/services/price_analyzer.dart';

import '../support/json_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CatalogPriceAnalyzer analyzer() {
    final bundle = JsonAssetBundle(
      jsonEncode({
        'gpu': [
          {
            'model': 'MAXSUN GeForce RTX 4060 8GB GDDR6 Terminator',
            'price': 4200000,
          },
          {'model': 'MSI GeForce RTX 4060 8GB GDDR6 Ventus', 'price': 4500000},
          {'model': 'ASUS GeForce RTX 4060 8GB GDDR6 Dual', 'price': 5000000},
          {
            'model': 'Gigabyte GeForce RTX 4060 8GB GDDR6 Eagle',
            'price': 4400000,
          },
          {
            'model': 'Zotac GeForce RTX 4060 8GB GDDR6 Twin Edge',
            'price': 4600000,
          },
          {'model': 'MAXSUN GeForce RTX 4060 Ti 8GB GDDR6', 'price': 7000000},
          {'model': 'MSI GeForce RTX 4060 Ti 8GB GDDR6', 'price': 7200000},
          {'model': 'ASUS GeForce RTX 4060 Ti 8GB GDDR6', 'price': 7500000},
          {'model': 'ASRock Radeon RX 7600 8GB GDDR6', 'price': 3500000},
          {'model': 'Sapphire Radeon RX 7600 8GB GDDR6', 'price': 3600000},
          {
            'model': 'ASRock Intel ARC Pro B70 32GB GDDR6 Creator',
            'price': 28290000,
          },
        ],
        'cpu': [
          {'model': 'AMD Ryzen 5 5600 3.5GHz 6 Core AM4', 'price': 1900000},
          {
            'model': 'AMD Ryzen 5 5600 3.5GHz 6 Core AM4 [Tray]',
            'price': 2000000,
          },
          {
            'model': 'AMD Ryzen 5 5600 3.5GHz 6 Core AM4 [Box]',
            'price': 2100000,
          },
          {'model': 'AMD Ryzen 7 5800X 3.8GHz 8 Core AM4', 'price': 3400000},
          {
            'model': 'AMD Ryzen 7 5800X 3.8GHz 8 Core AM4 [Box]',
            'price': 3500000,
          },
        ],
      }),
    );
    return CatalogPriceAnalyzer(CatalogService(bundle));
  }

  group('CatalogPriceAnalyzer verdict', () {
    test('harga di bawah median menghasilkan Worth It', () async {
      final analysis = await analyzer().analyze(
        PriceCheckRequest(query: 'RTX 4060', price: 4000000),
      );

      expect(analysis.referencePrice, 4500000);
      expect(analysis.verdict, isA<WorthItVerdict>());
      expect(analysis.score, greaterThanOrEqualTo(85));
      expect(analysis.fairPriceLow, 4050000);
      expect(analysis.fairPriceHigh, 4950000);
      expect(analysis.comparisons, isNotEmpty);
      expect(analysis.comparisons.first.title, contains('RTX 4060'));
      expect(analysis.comparisons.first.title, isNot(contains('Ti')));
      expect(analysis.comparisons.first.similarity, greaterThan(0));
    });

    test('harga di sekitar median menghasilkan Wajar', () async {
      final analysis = await analyzer().analyze(
        PriceCheckRequest(query: 'RTX 4060', price: 4550000),
      );

      expect(analysis.verdict, isA<FairVerdict>());
      expect(analysis.score, inInclusiveRange(70, 85));
    });

    test('harga jauh di atas median menghasilkan Kemahalan', () async {
      final analysis = await analyzer().analyze(
        PriceCheckRequest(query: 'RTX 4060', price: 6500000),
      );

      expect(analysis.verdict, isA<OverpricedVerdict>());
      expect(analysis.score, lessThan(70));
    });

    test('seri Ti memakai median seri Ti sendiri', () async {
      final analysis = await analyzer().analyze(
        PriceCheckRequest(query: 'RTX 4060 Ti', price: 7200000),
      );

      expect(analysis.referencePrice, 7200000);
      expect(analysis.verdict, isA<FairVerdict>());
    });
  });

  group('CatalogPriceAnalyzer pencarian', () {
    test('query tanpa spasi dan kapital tetap cocok', () async {
      final analysis = await analyzer().analyze(
        PriceCheckRequest(query: 'rtx4060', price: 4000000),
      );

      expect(analysis.referencePrice, 4500000);
      expect(analysis.verdict, isA<WorthItVerdict>());
    });

    test('query CPU memakai median seri CPU', () async {
      final analysis = await analyzer().analyze(
        PriceCheckRequest(query: 'Ryzen 5 5600', price: 1800000),
      );

      expect(analysis.referencePrice, 2000000);
      expect(analysis.verdict, isA<WorthItVerdict>());
      expect(analysis.comparisons.first.title, contains('Ryzen 5 5600'));
    });

    test('produk tidak dikenal memberi data terbatas', () async {
      final analysis = await analyzer().analyze(
        PriceCheckRequest(query: 'Produk Fiktif 999', price: 1000000),
      );

      expect(analysis.referencePrice, 0);
      expect(analysis.score, 0);
      expect(analysis.verdict, isA<LimitedDataVerdict>());
      expect(analysis.comparisons, isEmpty);
      expect(analysis.fairPriceLow, 0);
      expect(analysis.fairPriceHigh, 0);
    });

    test('varian tunggal tetap terbatas walau query cocok', () async {
      final analysis = await analyzer().analyze(
        PriceCheckRequest(query: 'ARC Pro B70', price: 28000000),
      );

      expect(analysis.referencePrice, 28290000);
      expect(analysis.verdict, isA<LimitedDataVerdict>());
      expect(analysis.comparisons, hasLength(1));
    });

    test('jumlah pembanding dibatasi delapan', () async {
      final analysis = await analyzer().analyze(
        PriceCheckRequest(query: 'RTX 4060', price: 4500000),
      );

      expect(analysis.comparisons.length, lessThanOrEqualTo(8));
      expect(analysis.comparisons.length, 8);
    });
  });
}

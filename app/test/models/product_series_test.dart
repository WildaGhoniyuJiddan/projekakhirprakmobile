import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/models/catalog_item.dart';
import 'package:worthbang_lite/models/product_series.dart';

void main() {
  group('ProductSeries', () {
    final variants = [
      const GpuItem(model: 'ASUS RTX 4060 Dual 8GB GDDR6', price: 4800000),
      const GpuItem(model: 'MSI RTX 4060 Ventus 8GB GDDR6', price: 4500000),
      const GpuItem(model: 'Gigabyte RTX 4060 Eagle 8GB GDDR6', price: 4200000),
    ];

    test('fromItems mengagregasi varian, harga, dan spesifikasi', () {
      final series = ProductSeries.fromItems(
        id: 'gpu:rtx-4060',
        name: 'RTX 4060',
        category: 'gpu',
        imageAsset: 'assets/images/gpu.png',
        variants: variants,
      );

      expect(series.variantCount, 3);
      expect(series.minPrice, 4200000);
      expect(series.maxPrice, 4800000);
      expect(series.categoryLabel, 'GPU');
      expect(series.specs['VRAM'], '8GB');
      expect(series.specs['Memori'], 'GDDR6');
      expect(series.specs['Brand'], 'ASUS');
      expect(series.priceRangeLabel, contains('Rp'));
      expect(series.priceRangeLabel, contains('–'));
    });

    test('redirecting constructor .empty aman untuk state awal', () {
      final series = ProductSeries.empty();
      expect(series.id, 'empty');
      expect(series.variantCount, 0);
      expect(series.minPrice, 0);
      expect(series.maxPrice, 0);
      expect(series.specs, isEmpty);
      expect(series.categoryLabel, 'Komponen');
    });

    test('fromItems menolak daftar varian kosong', () {
      expect(
        () => ProductSeries.fromItems(
          id: 'empty',
          name: 'Kosong',
          category: 'gpu',
          imageAsset: 'assets/images/gpu.png',
          variants: const [],
        ),
        throwsArgumentError,
      );
    });
  });
}

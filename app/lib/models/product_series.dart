import 'dart:math';

import '../core/utils/formatters.dart';
import '../core/utils/spec_parser.dart';
import 'catalog_item.dart';

/// Satu seri produk pada etalase.
///
/// Satu `ProductSeries` menampung banyak varian (mis. semua RTX 4060 dari
/// berbagai brand). Kartu etalase menampilkan satu seri; halaman detail
/// menampilkan seluruh varian dan spesifikasinya.
class ProductSeries {
  ProductSeries({
    required this.id,
    required this.name,
    required this.category,
    required this.imageAsset,
    required List<CatalogItem> variants,
  }) : _variants = List.unmodifiable(variants),
       _minPrice = variants.isEmpty
           ? 0
           : variants.map((item) => item.price).reduce(min),
       _maxPrice = variants.isEmpty
           ? 0
           : variants.map((item) => item.price).reduce(max),
       _specs = variants.isEmpty
           ? const {}
           : Map.unmodifiable(SpecParser.parse(category, variants.first.model));

  /// Redirecting constructor: template saat data etalase belum siap.
  ProductSeries.empty()
    : this(
        id: 'empty',
        name: 'Belum ada produk',
        category: 'gpu',
        imageAsset: 'assets/images/gpu.png',
        variants: const [],
      );

  /// Named constructor: agregasi varian menjadi satu seri.
  factory ProductSeries.fromItems({
    required String id,
    required String name,
    required String category,
    required String imageAsset,
    required List<CatalogItem> variants,
  }) {
    if (variants.isEmpty) {
      throw ArgumentError('Seri $name tidak punya varian.');
    }
    return ProductSeries(
      id: id,
      name: name,
      category: category,
      imageAsset: imageAsset,
      variants: variants,
    );
  }

  final String id;
  final String name;
  final String category;
  final String imageAsset;
  final List<CatalogItem> _variants;
  final int _minPrice;
  final int _maxPrice;
  final Map<String, String> _specs;

  List<CatalogItem> get variants => _variants;
  int get minPrice => _minPrice;
  int get maxPrice => _maxPrice;
  int get variantCount => _variants.length;
  Map<String, String> get specs => _specs;

  String get categoryLabel =>
      _variants.isEmpty ? 'Komponen' : _variants.first.sectionLabel;

  String get priceRangeLabel => _minPrice == _maxPrice
      ? formatRupiah(_minPrice)
      : '${formatRupiah(_minPrice)} – ${formatRupiah(_maxPrice)}';
}

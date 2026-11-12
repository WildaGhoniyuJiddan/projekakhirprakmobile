import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/utils/series_key.dart';
import '../models/catalog_item.dart';
import '../models/product_series.dart';

/// Memuat katalog retail dari aset lokal dan mengelompokkannya per seri.
class CatalogService {
  CatalogService(this._bundle);

  static const catalogAssetPath = 'assets/data/retail_catalog.json';

  final AssetBundle _bundle;

  List<CatalogItem>? _items;
  List<ProductSeries>? _series;

  Future<List<CatalogItem>> loadItems() async {
    final cached = _items;
    if (cached != null) return cached;

    final raw = await _bundle.loadString(catalogAssetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Format katalog tidak valid.');
    }

    final items = <CatalogItem>[];
    for (final entry in decoded.entries) {
      final rows = entry.value;
      if (rows is! List) continue;

      for (final row in rows) {
        if (row is! Map) continue;
        try {
          items.add(
            CatalogItem.fromJson(
              entry.key.toString(),
              Map<String, dynamic>.from(row),
            ),
          );
        } on Object {
          // Baris rusak/seksi tak dikenal tidak boleh menjatuhkan etalase.
          continue;
        }
      }
    }

    if (items.isEmpty) {
      throw const FormatException('Katalog tidak berisi item valid.');
    }

    _items = List.unmodifiable(items);
    return _items!;
  }

  Future<List<ProductSeries>> loadSeries() async {
    final cached = _series;
    if (cached != null) return cached;

    final items = await loadItems();
    final grouped = <String, List<CatalogItem>>{};
    for (final item in items) {
      final key = '${item.section}:${item.seriesKey}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final series =
        grouped.entries.map((entry) {
          final variants = List<CatalogItem>.of(entry.value)
            ..sort((a, b) => a.price.compareTo(b.price));
          final first = variants.first;

          return ProductSeries.fromItems(
            id: entry.key,
            name: SeriesKey.display(first.section, first.seriesKey),
            category: first.section,
            imageAsset: imageFor(first.section),
            variants: variants,
          );
        }).toList()..sort((a, b) {
          final byCount = b.variantCount.compareTo(a.variantCount);
          if (byCount != 0) return byCount;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

    _series = List.unmodifiable(series);
    return _series!;
  }

  static String imageFor(String section) => switch (section) {
    'cpu' => 'assets/images/cpu.png',
    'gpu' => 'assets/images/gpu.png',
    'motherboard' => 'assets/images/motherboard.png',
    'ram' => 'assets/images/ram.png',
    'storage' => 'assets/images/storage.png',
    _ => 'assets/images/gpu.png',
  };
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/utils/series_key.dart';
import '../models/catalog_item.dart';
import '../models/product_series.dart';

/// Hasil parsing katalog dalam satu pass (items + seri terkelompok).
class _ParsedCatalog {
  const _ParsedCatalog({required this.items, required this.series});

  final List<CatalogItem> items;
  final List<ProductSeries> series;
}

/// Top-level function untuk parsing katalog di background isolate via `compute`.
_ParsedCatalog _parseCatalogJson(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map) {
    throw const FormatException('Format katalog tidak valid.');
  }

  final items = <CatalogItem>[];
  final grouped = <String, List<CatalogItem>>{};

  for (final entry in decoded.entries) {
    final rows = entry.value;
    if (rows is! List) continue;
    final section = entry.key.toString();

    for (final row in rows) {
      if (row is! Map) continue;
      try {
        final item = CatalogItem.fromJson(
          section,
          Map<String, dynamic>.from(row),
        );
        items.add(item);
        final key = '${item.section}:${item.seriesKey}';
        grouped.putIfAbsent(key, () => []).add(item);
      } on Object {
        // Baris rusak/seksi tak dikenal tidak boleh menjatuhkan etalase.
        continue;
      }
    }
  }

  if (items.isEmpty) {
    throw const FormatException('Katalog tidak berisi item valid.');
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
          imageAsset: CatalogService.imageFor(first.section),
          variants: variants,
        );
      }).toList()..sort((a, b) {
        final byCount = b.variantCount.compareTo(a.variantCount);
        if (byCount != 0) return byCount;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

  return _ParsedCatalog(
    items: List.unmodifiable(items),
    series: List.unmodifiable(series),
  );
}

/// Memuat katalog retail dari aset lokal dan mengelompokkannya per seri.
class CatalogService {
  CatalogService(this._bundle, {this.useIsolate = true});

  static const catalogAssetPath = 'assets/data/retail_catalog.json';
  static const _isolateThresholdBytes = 50000;

  final AssetBundle _bundle;
  final bool useIsolate;

  List<CatalogItem>? _items;
  List<ProductSeries>? _series;
  Future<_ParsedCatalog>? _pendingLoad;

  /// Akses sinkron cache seri jika sudah selesai dimuat sebelumnya.
  List<ProductSeries>? get cachedSeries => _series;

  Future<_ParsedCatalog> _ensureLoaded() {
    final items = _items;
    final series = _series;
    if (items != null && series != null) {
      return Future.value(_ParsedCatalog(items: items, series: series));
    }

    final pending = _pendingLoad;
    if (pending != null) return pending;

    final future = _loadFromAsset();
    _pendingLoad = future;
    return future;
  }

  Future<_ParsedCatalog> _loadFromAsset() async {
    try {
      final raw = await _bundle.loadString(catalogAssetPath);
      final parsed = useIsolate && raw.length >= _isolateThresholdBytes
          ? await compute(_parseCatalogJson, raw)
          : _parseCatalogJson(raw);

      _items = parsed.items;
      _series = parsed.series;
      return parsed;
    } finally {
      _pendingLoad = null;
    }
  }

  Future<List<CatalogItem>> loadItems() async {
    final cached = _items;
    if (cached != null) return cached;
    return (await _ensureLoaded()).items;
  }

  Future<List<ProductSeries>> loadSeries() async {
    final cached = _series;
    if (cached != null) return cached;
    return (await _ensureLoaded()).series;
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

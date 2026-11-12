import '../core/utils/series_key.dart';

/// Entitas katalog dengan hierarki tipe komponen.
///
/// Setiap subclass menentukan label seksi dan cara menghitung harga
/// referensinya sendiri (polymorphism).
abstract class CatalogItem {
  const CatalogItem({required this.model, required this.price});

  final String model;
  final int price;

  String get section;
  String get sectionLabel;

  /// Kunci seri yang dipakai untuk grouping etalase dan harga referensi.
  String get seriesKey => SeriesKey.of(section, model);

  /// Harga referensi item ini terhadap kumpulan kandidat.
  int referencePrice(List<CatalogItem> pool);

  /// Median harga kandidat; fallback ke harga item ini jika kosong.
  int medianOrSelf(Iterable<int> values) {
    final sorted = values.toList()..sort();
    if (sorted.isEmpty) return price;
    return sorted[sorted.length ~/ 2];
  }

  /// Nama pendek untuk kartu/etalase.
  String get displayName {
    final short = model.split(' - ').first.trim();
    return short.isEmpty ? model : short;
  }

  Set<String> get searchTokens => model
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.length > 1)
      .toSet();

  factory CatalogItem.fromJson(String section, Map<String, dynamic> json) {
    final model = json['model'] as String?;
    final price = (json['price'] as num?)?.toInt();
    if (model == null || model.trim().isEmpty || price == null || price <= 0) {
      throw FormatException('Item katalog tidak valid pada seksi $section.');
    }

    return switch (section) {
      'cpu' => CpuItem(model: model, price: price),
      'gpu' => GpuItem(model: model, price: price),
      'motherboard' => MotherboardItem(model: model, price: price),
      'ram' => RamItem(model: model, price: price),
      'storage' => StorageItem(model: model, price: price),
      _ => throw ArgumentError('Seksi katalog tidak dikenal: $section'),
    };
  }
}

class CpuItem extends CatalogItem {
  const CpuItem({required super.model, required super.price});

  @override
  String get section => 'cpu';

  @override
  String get sectionLabel => 'CPU';

  @override
  int referencePrice(List<CatalogItem> pool) {
    final key = seriesKey;
    return medianOrSelf(
      pool
          .whereType<CpuItem>()
          .where((item) => item.seriesKey == key)
          .map((item) => item.price),
    );
  }
}

class GpuItem extends CatalogItem {
  const GpuItem({required super.model, required super.price});

  @override
  String get section => 'gpu';

  @override
  String get sectionLabel => 'GPU';

  @override
  int referencePrice(List<CatalogItem> pool) {
    final key = seriesKey;
    return medianOrSelf(
      pool
          .whereType<GpuItem>()
          .where((item) => item.seriesKey == key)
          .map((item) => item.price),
    );
  }
}

class MotherboardItem extends CatalogItem {
  const MotherboardItem({required super.model, required super.price});

  @override
  String get section => 'motherboard';

  @override
  String get sectionLabel => 'Motherboard';

  @override
  int referencePrice(List<CatalogItem> pool) {
    final key = seriesKey;
    return medianOrSelf(
      pool
          .whereType<MotherboardItem>()
          .where((item) => item.seriesKey == key)
          .map((item) => item.price),
    );
  }
}

class RamItem extends CatalogItem {
  const RamItem({required super.model, required super.price});

  @override
  String get section => 'ram';

  @override
  String get sectionLabel => 'RAM';

  @override
  int referencePrice(List<CatalogItem> pool) {
    final key = seriesKey;
    return medianOrSelf(
      pool
          .whereType<RamItem>()
          .where((item) => item.seriesKey == key)
          .map((item) => item.price),
    );
  }
}

class StorageItem extends CatalogItem {
  const StorageItem({required super.model, required super.price});

  @override
  String get section => 'storage';

  @override
  String get sectionLabel => 'Storage';

  @override
  int referencePrice(List<CatalogItem> pool) {
    final key = seriesKey;
    return medianOrSelf(
      pool
          .whereType<StorageItem>()
          .where((item) => item.seriesKey == key)
          .map((item) => item.price),
    );
  }
}

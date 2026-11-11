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

  /// Harga referensi item ini terhadap kumpulan kandidat.
  int referencePrice(List<CatalogItem> pool);

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
  int referencePrice(List<CatalogItem> pool) => price;
}

class GpuItem extends CatalogItem {
  const GpuItem({required super.model, required super.price});

  @override
  String get section => 'gpu';

  @override
  String get sectionLabel => 'GPU';

  @override
  int referencePrice(List<CatalogItem> pool) => price;
}

class MotherboardItem extends CatalogItem {
  const MotherboardItem({required super.model, required super.price});

  @override
  String get section => 'motherboard';

  @override
  String get sectionLabel => 'Motherboard';

  @override
  int referencePrice(List<CatalogItem> pool) {
    final chipset = _chipsetOf(model);
    final candidates = pool
        .whereType<MotherboardItem>()
        .where((item) => chipset == null || _chipsetOf(item.model) == chipset)
        .map((item) => item.price)
        .toList();
    return _medianOrSelf(candidates);
  }

  int _medianOrSelf(List<int> values) {
    if (values.isEmpty) return price;
    values.sort();
    return values[values.length ~/ 2];
  }

  static String? _chipsetOf(String value) {
    final match = RegExp(
      r'\b(A520|A620|B450|B550|B650|B760|B840|H610|H81|H310|H410|H510|X470|X570|X670|Z690|Z790)[A-Z]*',
      caseSensitive: false,
    ).firstMatch(value);
    return match?.group(1)?.toUpperCase();
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
    final capacity = _capacityOf(model);
    final candidates = pool
        .whereType<RamItem>()
        .where(
          (item) => capacity == null || _capacityOf(item.model) == capacity,
        )
        .map((item) => item.price)
        .toList();
    return _medianOrSelf(candidates);
  }

  int _medianOrSelf(List<int> values) {
    if (values.isEmpty) return price;
    values.sort();
    return values[values.length ~/ 2];
  }

  static String? _capacityOf(String value) {
    final match = RegExp(
      r'\b(\d{1,2})\s?GB\b',
      caseSensitive: false,
    ).firstMatch(value);
    return match?.group(1);
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
    final capacity = _capacityOf(model);
    final candidates = pool
        .whereType<StorageItem>()
        .where(
          (item) => capacity == null || _capacityOf(item.model) == capacity,
        )
        .map((item) => item.price)
        .toList();
    return _medianOrSelf(candidates);
  }

  int _medianOrSelf(List<int> values) {
    if (values.isEmpty) return price;
    values.sort();
    return values[values.length ~/ 2];
  }

  static String? _capacityOf(String value) {
    final match = RegExp(
      r'\b(\d{1,4}\s?(?:GB|TB))\b',
      caseSensitive: false,
    ).firstMatch(value);
    return match?.group(1)?.replaceAll(' ', '').toUpperCase();
  }
}

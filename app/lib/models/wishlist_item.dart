import 'package:hive/hive.dart';

/// Item wishlist yang disimpan di Hive.
///
/// Field privat + getter/setter menjaga agar data ilegal tidak pernah masuk
/// ke database lokal.
class WishlistItem extends HiveObject {
  WishlistItem({
    required String query,
    required int targetPrice,
    String condition = 'baru',
  }) : _query = _validateQuery(query),
       _targetPrice = _validateTargetPrice(targetPrice),
       _condition = _validateCondition(condition);

  /// Redirecting constructor: template form wishlist.
  WishlistItem.empty() : this(query: 'Produk baru', targetPrice: 1000000);

  /// Named constructor: dari Map (migrasi/backup).
  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      query: map['query'] as String? ?? '',
      targetPrice: (map['target_price'] as num?)?.toInt() ?? 0,
      condition: map['condition'] as String? ?? 'baru',
    );
  }

  String _query;
  int _targetPrice;
  String _condition;

  String get query => _query;
  int get targetPrice => _targetPrice;
  String get condition => _condition;

  set query(String value) => _query = _validateQuery(value);
  set targetPrice(int value) => _targetPrice = _validateTargetPrice(value);
  set condition(String value) => _condition = _validateCondition(value);

  Map<String, dynamic> toMap() => {
    'query': _query,
    'target_price': _targetPrice,
    'condition': _condition,
  };

  WishlistItem copyWith({String? query, int? targetPrice, String? condition}) {
    return WishlistItem(
      query: query ?? _query,
      targetPrice: targetPrice ?? _targetPrice,
      condition: condition ?? _condition,
    );
  }

  static String _validateQuery(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      throw ArgumentError('Nama produk minimal 2 karakter.');
    }
    return trimmed;
  }

  static int _validateTargetPrice(int value) {
    if (value <= 0) {
      throw ArgumentError('Target harga harus lebih dari 0.');
    }
    return value;
  }

  static String _validateCondition(String value) {
    const allowed = {'baru', 'bekas', 'any'};
    if (!allowed.contains(value)) {
      throw ArgumentError('Kondisi tidak valid: $value');
    }
    return value;
  }
}

/// Adapter Hive manual — tanpa generator.
class WishlistItemAdapter extends TypeAdapter<WishlistItem> {
  @override
  final int typeId = 0;

  @override
  WishlistItem read(BinaryReader reader) {
    final query = reader.readString();
    final targetPrice = reader.readInt();
    final condition = reader.readString();
    return WishlistItem(
      query: query,
      targetPrice: targetPrice,
      condition: condition,
    );
  }

  @override
  void write(BinaryWriter writer, WishlistItem obj) {
    writer
      ..writeString(obj.query)
      ..writeInt(obj.targetPrice)
      ..writeString(obj.condition);
  }
}

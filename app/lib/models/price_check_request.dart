/// Permintaan cek harga dengan enkapsulasi dan validasi state.
class PriceCheckRequest {
  String _query;
  int _price;
  String _condition;

  /// Generative constructor + validasi awal.
  PriceCheckRequest({
    required String query,
    required int price,
    String condition = 'baru',
  }) : _query = _validateQuery(query),
       _price = _validatePrice(price),
       _condition = _validateCondition(condition);

  /// Named constructor: dari JSON (API/Hive).
  factory PriceCheckRequest.fromJson(Map<String, dynamic> json) {
    return PriceCheckRequest(
      query: json['query'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      condition: json['condition'] as String? ?? 'baru',
    );
  }

  /// Redirecting constructor: data awal form.
  PriceCheckRequest.empty() : this(query: 'RTX 4060', price: 4500000);

  String get query => _query;
  int get price => _price;
  String get condition => _condition;

  set query(String value) => _query = _validateQuery(value);
  set price(int value) => _price = _validatePrice(value);
  set condition(String value) => _condition = _validateCondition(value);

  Map<String, dynamic> toJson() => {
    'query': _query,
    'price': _price,
    'condition': _condition,
  };

  static String _validateQuery(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      throw ArgumentError('Nama produk minimal 2 karakter.');
    }
    if (trimmed.length > 255) {
      throw ArgumentError('Nama produk maksimal 255 karakter.');
    }
    return trimmed;
  }

  static int _validatePrice(int value) {
    if (value <= 0) {
      throw ArgumentError('Harga harus lebih dari 0.');
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

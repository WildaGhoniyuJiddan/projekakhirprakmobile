/// Toko komputer pada data lokal.
class Store {
  const Store({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
    this.prices = const {},
    this.distanceKm = 0,
  });

  final int id;
  final String name;
  final String address;
  final String city;
  final double lat;
  final double lng;
  final Map<String, int> prices;
  final double distanceKm;

  factory Store.fromJson(Map<String, dynamic> json) {
    final rawPrices = json['prices'];
    final prices = <String, int>{};
    if (rawPrices is Map) {
      for (final entry in rawPrices.entries) {
        final value = entry.value;
        if (value is num) prices[entry.key.toString()] = value.toInt();
      }
    }

    return Store(
      id: (json['id'] as num? ?? 0).toInt(),
      name: json['name'] as String? ?? '-',
      address: json['address'] as String? ?? '-',
      city: json['city'] as String? ?? '-',
      lat: (json['lat'] as num? ?? 0).toDouble(),
      lng: (json['lng'] as num? ?? 0).toDouble(),
      prices: prices,
      distanceKm: (json['distance_km'] as num? ?? 0).toDouble(),
    );
  }

  Store copyWithDistance(double value) => Store(
    id: id,
    name: name,
    address: address,
    city: city,
    lat: lat,
    lng: lng,
    prices: prices,
    distanceKm: value,
  );

  int? priceFor(String query) {
    final normalized = query.trim().toLowerCase();
    for (final entry in prices.entries) {
      if (entry.key.toLowerCase() == normalized) return entry.value;
    }
    return null;
  }
}

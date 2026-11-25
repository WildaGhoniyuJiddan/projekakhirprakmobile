import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/store.dart';

/// Memuat daftar toko komputer lokal dan menghitung jarak dari posisi user.
class StoreService {
  StoreService(this._bundle);

  static const storesAssetPath = 'assets/data/stores.json';

  final AssetBundle _bundle;

  List<Store>? _stores;

  Future<List<Store>> loadStores() async {
    final cached = _stores;
    if (cached != null) return cached;

    final raw = await _bundle.loadString(storesAssetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Format data toko tidak valid.');
    }

    final stores = <Store>[];
    for (final row in decoded) {
      if (row is! Map) continue;
      try {
        final store = Store.fromJson(Map<String, dynamic>.from(row));
        if (store.lat == 0 && store.lng == 0) continue;
        stores.add(store);
      } on Object {
        // Satu baris rusak tidak boleh menjatuhkan daftar toko.
        continue;
      }
    }

    if (stores.isEmpty) {
      throw const FormatException('Data toko tidak berisi entri valid.');
    }

    _stores = List.unmodifiable(stores);
    return _stores!;
  }

  /// Toko yang cocok dengan [query] dan sudah dihitung jaraknya dari [lat]/[lng].
  ///
  /// Tanpa query, hanya toko dalam [radiusKm] yang diambil. Dengan query,
  /// semua toko yang cocok tetap ditampilkan agar pencarian nama toko atau
  /// produk tidak kosong hanya karena berada di luar radius.
  Future<List<Store>> nearby({
    required double lat,
    required double lng,
    String query = '',
    double radiusKm = 25,
  }) async {
    final all = await loadStores();
    final keyword = query.trim().toLowerCase();
    final result = <Store>[];

    for (final store in all) {
      final distance = distanceKm(lat, lng, store.lat, store.lng);
      if (keyword.isNotEmpty) {
        if (!_matchesQuery(store, keyword)) continue;
      } else if (distance > radiusKm) {
        continue;
      }
      result.add(store.copyWithDistance(distance));
    }

    result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return result;
  }

  static bool _matchesQuery(Store store, String keyword) {
    if (store.name.toLowerCase().contains(keyword)) return true;
    if (store.address.toLowerCase().contains(keyword)) return true;
    if (store.city.toLowerCase().contains(keyword)) return true;
    return store.prices.keys.any(
      (product) => product.toLowerCase().contains(keyword),
    );
  }

  /// Jarak great-circle dua koordinat dalam kilometer.
  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;
    final dLat = _radians(lat2 - lat1);
    final dLng = _radians(lng2 - lng1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_radians(lat1)) *
            cos(_radians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return 2 * earthRadiusKm * asin(sqrt(a));
  }

  static double _radians(double degrees) => degrees * pi / 180;
}

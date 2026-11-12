import 'package:hive/hive.dart';

import '../models/wishlist_item.dart';

/// CRUD penuh wishlist di Hive.
class WishlistRepository {
  WishlistRepository(this._box);

  final Box<WishlistItem> _box;

  // Create
  Future<int> add(WishlistItem item) => _box.add(item);

  // Read
  List<WishlistItem> getAll() => _box.values.toList();

  WishlistItem? getAt(int index) {
    if (index < 0 || index >= _box.length) return null;
    return _box.getAt(index);
  }

  // Update
  Future<void> updateAt(int index, WishlistItem item) =>
      _box.putAt(index, item);

  // Delete
  Future<void> deleteAt(int index) => _box.deleteAt(index);

  int get length => _box.length;

  bool containsQuery(String query) {
    final normalized = query.trim().toLowerCase();
    return _box.values.any((item) => item.query.toLowerCase() == normalized);
  }
}

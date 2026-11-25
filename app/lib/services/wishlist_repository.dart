import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/wishlist_item.dart';

/// CRUD penuh wishlist di Hive.
class WishlistRepository extends ChangeNotifier {
  WishlistRepository(this._box);

  final Box<WishlistItem> _box;

  // Create
  Future<int> add(WishlistItem item) async {
    final key = await _box.add(item);
    notifyListeners();
    return key;
  }

  // Read
  List<WishlistItem> getAll() => _box.values.toList();

  WishlistItem? getAt(int index) {
    if (index < 0 || index >= _box.length) return null;
    return _box.getAt(index);
  }

  // Update
  Future<void> updateAt(int index, WishlistItem item) async {
    await _box.putAt(index, item);
    notifyListeners();
  }

  // Delete
  Future<void> deleteAt(int index) async {
    await _box.deleteAt(index);
    notifyListeners();
  }

  int get length => _box.length;

  bool containsQuery(String query) {
    final normalized = query.trim().toLowerCase();
    return _box.values.any((item) => item.query.toLowerCase() == normalized);
  }
}

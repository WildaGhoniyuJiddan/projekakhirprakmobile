import 'package:hive_flutter/hive_flutter.dart';

import '../models/wishlist_item.dart';

/// Bootstrap Hive: inisialisasi direktori, adapter, dan box aplikasi.
class HiveService {
  static const wishlistBoxName = 'wishlist';
  static const historyBoxName = 'history';
  static const accountsBoxName = 'accounts';

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WishlistItemAdapter());
    }

    await Hive.openBox<WishlistItem>(wishlistBoxName);
    await Hive.openBox<dynamic>(historyBoxName);
    await Hive.openBox<dynamic>(accountsBoxName);
  }

  static Box<WishlistItem> get wishlistBox =>
      Hive.box<WishlistItem>(wishlistBoxName);

  static Box<dynamic> get historyBox => Hive.box<dynamic>(historyBoxName);

  static Box<dynamic> get accountsBox => Hive.box<dynamic>(accountsBoxName);
}

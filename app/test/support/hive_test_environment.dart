import 'dart:io';

import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worthbang_lite/models/wishlist_item.dart';
import 'package:worthbang_lite/services/auth_service.dart';
import 'package:worthbang_lite/services/catalog_service.dart';
import 'package:worthbang_lite/services/history_repository.dart';
import 'package:worthbang_lite/services/notification_service.dart';
import 'package:worthbang_lite/services/price_analyzer.dart';
import 'package:worthbang_lite/services/session_preferences.dart';
import 'package:worthbang_lite/services/wishlist_repository.dart';
import 'package:worthbang_lite/state/app_dependencies.dart';
import 'package:worthbang_lite/state/session_controller.dart';
import 'package:worthbang_lite/state/theme_controller.dart';

import 'json_asset_bundle.dart';
import 'sample_catalog.dart';

/// Lingkungan Hive sementara yang dipakai bersama oleh test.
class HiveTestEnvironment {
  HiveTestEnvironment._(this._tempDir);

  final Directory _tempDir;

  late final Box<WishlistItem> wishlistBox;
  late final Box<dynamic> historyBox;
  late final Box<dynamic> accountsBox;

  static Future<HiveTestEnvironment> create() async {
    final dir = await Directory.systemTemp.createTemp('worthbang_hive_test_');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WishlistItemAdapter());
    }

    final env = HiveTestEnvironment._(dir);
    env.wishlistBox = await Hive.openBox<WishlistItem>('wishlist');
    env.historyBox = await Hive.openBox<dynamic>('history');
    env.accountsBox = await Hive.openBox<dynamic>('accounts');
    return env;
  }

  Future<AppDependencies> dependencies() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final sessionPreferences = SessionPreferences(prefs);

    final themeController = ThemeController(sessionPreferences);
    await themeController.load();

    final sessionController = SessionController(
      AuthService(accountsBox, sessionPreferences),
    );
    await sessionController.restore();

    final catalogService = CatalogService(JsonAssetBundle(sampleCatalogJson));

    return AppDependencies(
      sessionPreferences: sessionPreferences,
      sessionController: sessionController,
      themeController: themeController,
      wishlistRepository: WishlistRepository(wishlistBox),
      historyRepository: HistoryRepository(historyBox),
      catalogService: catalogService,
      priceAnalyzer: CatalogPriceAnalyzer(catalogService),
      notificationService: FakeNotificationService(),
    );
  }

  Future<void> clearBoxes() async {
    await wishlistBox.clear();
    await historyBox.clear();
    await accountsBox.clear();
  }

  Future<void> dispose() async {
    // ignore: avoid_print
    print('DEBUG: closing wishlistBox...');
    try {
      await wishlistBox.close().timeout(const Duration(seconds: 1));
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: wishlistBox close error: $e');
    }
    // ignore: avoid_print
    print('DEBUG: closing historyBox...');
    try {
      await historyBox.close().timeout(const Duration(seconds: 1));
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: historyBox close error: $e');
    }
    // ignore: avoid_print
    print('DEBUG: closing accountsBox...');
    try {
      await accountsBox.close().timeout(const Duration(seconds: 1));
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: accountsBox close error: $e');
    }
    // ignore: avoid_print
    print('DEBUG: closing Hive...');
    try {
      await Hive.close().timeout(const Duration(seconds: 1));
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Hive.close() error: $e');
    }
    // ignore: avoid_print
    print('DEBUG: deleting tempDir...');
    try {
      if (await _tempDir.exists()) {
        await _tempDir.delete(recursive: true);
      }
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: tempDir delete error: $e');
    }
    // ignore: avoid_print
    print('DEBUG: dispose all done');
  }
}

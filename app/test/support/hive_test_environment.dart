import 'dart:io';

import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worthbang_lite/models/wishlist_item.dart';
import 'package:worthbang_lite/services/auth_service.dart';
import 'package:worthbang_lite/services/catalog_service.dart';
import 'package:worthbang_lite/services/currency_api.dart';
import 'package:worthbang_lite/services/history_repository.dart';
import 'package:worthbang_lite/services/location_service.dart';
import 'package:worthbang_lite/services/notification_service.dart';
import 'package:worthbang_lite/services/price_analyzer.dart';
import 'package:worthbang_lite/services/session_preferences.dart';
import 'package:worthbang_lite/services/store_service.dart';
import 'package:worthbang_lite/services/wishlist_repository.dart';
import 'package:worthbang_lite/state/app_dependencies.dart';
import 'package:worthbang_lite/state/session_controller.dart';
import 'package:worthbang_lite/state/theme_controller.dart';

import 'fake_currency_service.dart';
import 'fake_location_service.dart';
import 'json_asset_bundle.dart';
import 'sample_catalog.dart';
import 'sample_stores.dart';

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

  Future<AppDependencies> dependencies({
    NotificationService? notificationService,
    LocationService? locationService,
    CurrencyService? currencyService,
  }) async {
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
      notificationService: notificationService ?? FakeNotificationService(),
      storeService: StoreService(JsonAssetBundle(sampleStoresJson)),
      locationService: locationService ?? FakeLocationService(),
      currencyService: currencyService ?? FakeCurrencyService(),
    );
  }

  Future<void> clearBoxes() async {
    await wishlistBox.clear();
    await historyBox.clear();
    await accountsBox.clear();
  }

  Future<void> dispose() async {
    for (final box in [wishlistBox, historyBox, accountsBox]) {
      try {
        await box.close().timeout(const Duration(seconds: 1));
      } on Object {
        // Box bisa masih sibuk saat suite dihentikan; abaikan agar test selesai.
      }
    }
    try {
      await Hive.close().timeout(const Duration(seconds: 1));
    } on Object {
      // Sama seperti di atas.
    }
    try {
      if (await _tempDir.exists()) {
        await _tempDir.delete(recursive: true);
      }
    } on Object {
      // File bisa masih dikunci proses lain di Windows.
    }
  }
}

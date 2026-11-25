import 'package:flutter/widgets.dart';

import '../services/catalog_service.dart';
import '../services/currency_api.dart';
import '../services/history_repository.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/price_analyzer.dart';
import '../services/session_preferences.dart';
import '../services/store_service.dart';
import '../services/wishlist_repository.dart';
import 'app_dependencies.dart';
import 'session_controller.dart';
import 'theme_controller.dart';

/// Dependency container sederhana untuk widget tree.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.dependencies, required super.child});

  final AppDependencies dependencies;

  ThemeController get themeController => dependencies.themeController;
  SessionController get sessionController => dependencies.sessionController;
  SessionPreferences get sessionPreferences => dependencies.sessionPreferences;
  WishlistRepository get wishlistRepository => dependencies.wishlistRepository;
  HistoryRepository get historyRepository => dependencies.historyRepository;
  CatalogService get catalogService => dependencies.catalogService;
  PriceAnalyzer get priceAnalyzer => dependencies.priceAnalyzer;
  NotificationService get notificationService =>
      dependencies.notificationService;
  StoreService get storeService => dependencies.storeService;
  LocationService get locationService => dependencies.locationService;
  CurrencyService get currencyService => dependencies.currencyService;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope tidak ditemukan di widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      oldWidget.dependencies != dependencies;
}

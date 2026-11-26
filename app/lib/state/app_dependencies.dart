import '../services/catalog_service.dart';
import '../services/currency_api.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/price_analyzer.dart';
import '../services/session_preferences.dart';
import '../services/store_service.dart';
import '../services/wishlist_repository.dart';
import 'session_controller.dart';
import 'theme_controller.dart';

/// Container dependency yang dibuat sekali saat bootstrap.
///
/// Widget mengaksesnya lewat `AppScope`, bukan membuat service sendiri.
class AppDependencies {
  const AppDependencies({
    required this.sessionPreferences,
    required this.sessionController,
    required this.themeController,
    required this.wishlistRepository,
    required this.catalogService,
    required this.priceAnalyzer,
    required this.notificationService,
    required this.storeService,
    required this.locationService,
    required this.currencyService,
  });

  final SessionPreferences sessionPreferences;
  final SessionController sessionController;
  final ThemeController themeController;
  final WishlistRepository wishlistRepository;
  final CatalogService catalogService;
  final PriceAnalyzer priceAnalyzer;
  final NotificationService notificationService;
  final StoreService storeService;
  final LocationService locationService;
  final CurrencyService currencyService;
}

import '../services/catalog_service.dart';
import '../services/history_repository.dart';
import '../services/price_analyzer.dart';
import '../services/session_preferences.dart';
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
    required this.historyRepository,
    required this.catalogService,
    required this.priceAnalyzer,
  });

  final SessionPreferences sessionPreferences;
  final SessionController sessionController;
  final ThemeController themeController;
  final WishlistRepository wishlistRepository;
  final HistoryRepository historyRepository;
  final CatalogService catalogService;
  final PriceAnalyzer priceAnalyzer;
}

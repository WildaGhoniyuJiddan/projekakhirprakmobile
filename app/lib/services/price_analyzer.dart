import '../models/catalog_item.dart';
import '../models/price_analysis.dart';
import '../models/price_check_request.dart';
import '../models/price_verdict.dart';
import 'catalog_service.dart';

/// Kontrak analyzer harga.
abstract class PriceAnalyzer {
  Future<PriceAnalysis> analyze(PriceCheckRequest request);
}

/// Analyzer berbasis katalog retail lokal.
///
/// Alur: cocokkan token query → hitung harga referensi polimorfik →
/// bandingkan harga user → tentukan skor dan verdict.
class CatalogPriceAnalyzer implements PriceAnalyzer {
  CatalogPriceAnalyzer(this._catalog);

  final CatalogService _catalog;

  static const _maxComparisons = 8;
  static const _worthThreshold = 0.10;
  static const _overThreshold = 0.10;

  @override
  Future<PriceAnalysis> analyze(PriceCheckRequest request) async {
    final items = await _catalog.loadItems();
    final tokens = _tokenize(request.query);
    final compactQuery = _compact(request.query);
    if (tokens.isEmpty || compactQuery.length < 2) {
      return _noData(request);
    }

    final matches = items
        .where((item) => _matches(item, tokens, compactQuery))
        .toList();
    if (matches.isEmpty) return _noData(request);

    matches.sort((a, b) => _compareMatches(a, b, compactQuery));

    final top = matches.first;
    final pool = matches.length > 40 ? matches.take(40).toList() : matches;
    final reference = top.referencePrice(pool);
    final sameSeries = matches
        .where((item) => item.seriesKey == top.seriesKey)
        .length;

    final verdict = reference <= 0 || sameSeries < 2
        ? const LimitedDataVerdict()
        : _verdictFor(request.price, reference);
    final score = reference <= 0 ? 0.0 : _scoreFor(request.price, reference);

    final comparisons = matches
        .take(_maxComparisons)
        .map(
          (item) => PriceComparison(
            title: item.model,
            price: item.price,
            source: 'Katalog retail',
            similarity: _similarity(item, tokens, compactQuery),
            condition: 'baru',
          ),
        )
        .toList();

    return PriceAnalysis(
      request: request,
      referencePrice: reference,
      score: score,
      verdict: verdict,
      comparisons: comparisons,
      fairPriceLow: reference <= 0 ? 0 : (reference * 0.9).round(),
      fairPriceHigh: reference <= 0 ? 0 : (reference * 1.1).round(),
    );
  }

  PriceAnalysis _noData(PriceCheckRequest request) => PriceAnalysis(
    request: request,
    referencePrice: 0,
    score: 0,
    verdict: const LimitedDataVerdict(),
    fairPriceLow: 0,
    fairPriceHigh: 0,
  );

  static bool _matches(
    CatalogItem item,
    Set<String> tokens,
    String compactQuery,
  ) {
    final compactModel = _compact(item.model);
    if (compactModel.contains(compactQuery)) return true;

    final modelTokens = _modelTokens(item.model);
    return tokens.every(
      (token) => modelTokens.contains(token) || compactModel.contains(token),
    );
  }

  static int _compareMatches(
    CatalogItem a,
    CatalogItem b,
    String compactQuery,
  ) {
    final aExact = _compact(a.seriesKey) == compactQuery;
    final bExact = _compact(b.seriesKey) == compactQuery;
    if (aExact != bExact) return aExact ? -1 : 1;

    final bySeriesLength = a.seriesKey.length.compareTo(b.seriesKey.length);
    if (bySeriesLength != 0) return bySeriesLength;

    return a.price.compareTo(b.price);
  }

  static double _similarity(
    CatalogItem item,
    Set<String> tokens,
    String compactQuery,
  ) {
    final compactModel = _compact(item.model);
    final modelTokens = _modelTokens(item.model);
    var matched = 0;
    for (final token in tokens) {
      if (modelTokens.contains(token) || compactModel.contains(token)) {
        matched++;
      }
    }

    final tokenScore = tokens.isEmpty ? 0.0 : matched / tokens.length;
    final exact = _compact(item.seriesKey) == compactQuery;
    return (tokenScore * 0.8 + (exact ? 0.2 : 0.05)).clamp(0, 1).toDouble();
  }

  static PriceVerdict _verdictFor(int price, int reference) {
    final difference = (price - reference) / reference;
    if (difference <= -_worthThreshold) return const WorthItVerdict();
    if (difference <= _overThreshold) return const FairVerdict();
    return const OverpricedVerdict();
  }

  static double _scoreFor(int price, int reference) {
    final difference = (price - reference) / reference;

    if (difference <= -_worthThreshold) {
      final gain = (-difference - _worthThreshold) / 0.30;
      return (85 + gain * 15).clamp(85, 100).toDouble();
    }

    if (difference < _overThreshold) {
      final position = (difference + _worthThreshold) / 0.20;
      return (85 - position * 15).clamp(70, 85).toDouble();
    }

    final excess = (difference - _overThreshold) / 0.50;
    return (70 - excess * 70).clamp(0, 70).toDouble();
  }

  static Set<String> _tokenize(String query) => query
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.length > 1)
      .toSet();

  static Set<String> _modelTokens(String model) => model
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.isNotEmpty)
      .toSet();

  static String _compact(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

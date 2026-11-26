import 'price_check_request.dart';
import 'price_verdict.dart';

/// Satu listing pembanding pada hasil analisis.
class PriceComparison {
  const PriceComparison({
    required this.title,
    required this.price,
    required this.source,
    this.similarity,
    this.condition,
  });

  final String title;
  final int price;
  final String source;
  final double? similarity;
  final String? condition;
}

/// Hasil analisis harga.
class PriceAnalysis {
  PriceAnalysis({
    required this.request,
    required this.referencePrice,
    required double score,
    required this.verdict,
    this.comparisons = const [],
    required this.fairPriceLow,
    required this.fairPriceHigh,
    DateTime? createdAt,
  }) : score = score.clamp(0, 100).toDouble(),
       createdAt = createdAt ?? DateTime.now();

  /// Redirecting constructor: hasil kosong untuk state awal.
  PriceAnalysis.empty()
    : this(
        request: PriceCheckRequest.empty(),
        referencePrice: 0,
        score: 0,
        verdict: const LimitedDataVerdict(),
        fairPriceLow: 0,
        fairPriceHigh: 0,
      );

  final PriceCheckRequest request;
  final int referencePrice;
  final double score;
  final PriceVerdict verdict;
  final List<PriceComparison> comparisons;
  final int fairPriceLow;
  final int fairPriceHigh;
  final DateTime createdAt;
}

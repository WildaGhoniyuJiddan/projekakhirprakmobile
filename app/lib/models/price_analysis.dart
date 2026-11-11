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

  factory PriceComparison.fromJson(Map<String, dynamic> json) {
    return PriceComparison(
      title: json['title'] as String? ?? '-',
      price: (json['price'] as num? ?? 0).toInt(),
      source: json['source'] as String? ?? '-',
      similarity: (json['similarity'] as num?)?.toDouble(),
      condition: json['condition'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'price': price,
    'source': source,
    'similarity': similarity,
    'condition': condition,
  };
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

  /// Named constructor: dari JSON/Hive.
  factory PriceAnalysis.fromJson(Map<String, dynamic> json) {
    final rawQuery = (json['query'] as String? ?? '').trim();
    final rawPrice = (json['price'] as num?)?.toInt();
    final rawCondition = json['condition'] as String? ?? 'baru';
    final request = PriceCheckRequest(
      query: rawQuery.length >= 2 ? rawQuery : 'Produk',
      price: rawPrice != null && rawPrice > 0 ? rawPrice : 1,
      condition: const {'baru', 'bekas', 'any'}.contains(rawCondition)
          ? rawCondition
          : 'baru',
    );
    final comparisons = (json['comparisons'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (item) => PriceComparison.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
    final reference = (json['reference_price'] as num?)?.toInt() ?? 0;
    final createdAt = DateTime.tryParse(json['created_at'] as String? ?? '');

    return PriceAnalysis(
      request: request,
      referencePrice: reference,
      score: (json['score'] as num? ?? 0).toDouble(),
      verdict: PriceVerdict.fromKey(
        json['verdict_key'] as String? ?? json['verdict'] as String?,
      ),
      comparisons: comparisons,
      fairPriceLow: (json['fair_price_low'] as num?)?.toInt() ?? reference,
      fairPriceHigh: (json['fair_price_high'] as num?)?.toInt() ?? reference,
      createdAt: createdAt,
    );
  }

  final PriceCheckRequest request;
  final int referencePrice;
  final double score;
  final PriceVerdict verdict;
  final List<PriceComparison> comparisons;
  final int fairPriceLow;
  final int fairPriceHigh;
  final DateTime createdAt;

  int get listingCount => comparisons.length;

  Map<String, dynamic> toJson() => {
    'query': request.query,
    'price': request.price,
    'condition': request.condition,
    'reference_price': referencePrice,
    'score': score,
    'verdict': verdict.label,
    'verdict_key': verdict.key,
    'fair_price_low': fairPriceLow,
    'fair_price_high': fairPriceHigh,
    'comparisons': comparisons.map((item) => item.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
  };
}

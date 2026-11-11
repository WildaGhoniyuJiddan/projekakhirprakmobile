/// Satu baris kurs mata uang terhadap IDR.
class CurrencyRate {
  const CurrencyRate({required this.code, required this.rate});

  final String code;
  final double rate;

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      code: (json['code'] as String? ?? '').toUpperCase(),
      rate: (json['rate'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'code': code, 'rate': rate};

  double convertFromIdr(double amount) => amount * rate;
}

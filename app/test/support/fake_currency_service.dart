import 'package:worthbang_lite/models/currency_rate.dart';
import 'package:worthbang_lite/services/currency_api.dart';

/// Layanan kurs palsu untuk kebutuhan widget test tanpa koneksi jaringan.
class FakeCurrencyService implements CurrencyService {
  FakeCurrencyService({List<CurrencyRate>? rates, this.error})
    : rates =
          rates ??
          const [
            CurrencyRate(code: 'USD', rate: 0.0000625),
            CurrencyRate(code: 'SGD', rate: 0.000084),
            CurrencyRate(code: 'JPY', rate: 0.0095),
          ];

  List<CurrencyRate> rates;
  Object? error;
  int fetchCount = 0;

  @override
  Future<List<CurrencyRate>> fetchRates() async {
    fetchCount++;
    final currentError = error;
    if (currentError != null) throw currentError;
    return rates;
  }

  @override
  void dispose() {}
}

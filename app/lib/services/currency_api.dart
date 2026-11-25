import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/currency_rate.dart';

/// Error yang dilempar saat permintaan kurs mata uang gagal diproses.
class CurrencyApiException implements Exception {
  const CurrencyApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Kontrak layanan pengambilan kurs mata uang terhadap IDR.
abstract class CurrencyService {
  Future<List<CurrencyRate>> fetchRates();
  void dispose();
}

/// Klien HTTP publik untuk mengambil kurs mata uang terhadap IDR.
class CurrencyApi implements CurrencyService {
  CurrencyApi({
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
    this.endpoint = defaultEndpoint,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  static const defaultEndpoint = 'https://open.er-api.com/v6/latest/IDR';

  /// Daftar mata uang populer untuk perbandingan harga komponen PC.
  static const featuredCodes = <String>[
    'USD',
    'SGD',
    'JPY',
    'EUR',
    'MYR',
    'CNY',
    'AUD',
    'GBP',
    'KRW',
    'TWD',
  ];

  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;
  final String endpoint;

  @override
  Future<List<CurrencyRate>> fetchRates() async {
    final http.Response response;
    try {
      response = await _client.get(Uri.parse(endpoint)).timeout(timeout);
    } on TimeoutException {
      throw const CurrencyApiException(
        'Permintaan kurs melebihi batas waktu. Periksa koneksi internetmu.',
      );
    } on Object {
      throw const CurrencyApiException(
        'Tidak dapat terhubung ke layanan kurs. Pastikan internet aktif.',
      );
    }

    if (response.statusCode != 200) {
      throw CurrencyApiException(
        'Layanan kurs sedang bermasalah (kode ${response.statusCode}).',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const CurrencyApiException('Format respons kurs tidak valid.');
    }

    if (decoded is! Map) {
      throw const CurrencyApiException('Data kurs tidak sesuai format.');
    }

    final rawRates = decoded['rates'];
    if (rawRates is! Map) {
      throw const CurrencyApiException('Daftar kurs tidak ditemukan.');
    }

    final normalized = <String, double>{};
    for (final entry in rawRates.entries) {
      final code = entry.key.toString().trim().toUpperCase();
      final value = entry.value;
      if (code.isEmpty || code == 'IDR' || value is! num) continue;
      final rate = value.toDouble();
      if (rate > 0 && rate.isFinite) {
        normalized[code] = rate;
      }
    }

    final rates = <CurrencyRate>[];
    for (final code in featuredCodes) {
      final rate = normalized[code];
      if (rate != null) {
        rates.add(CurrencyRate.fromJson({'code': code, 'rate': rate}));
      }
    }

    if (rates.isEmpty) {
      for (final entry in normalized.entries) {
        rates.add(
          CurrencyRate.fromJson({'code': entry.key, 'rate': entry.value}),
        );
      }
    }

    if (rates.isEmpty) {
      throw const CurrencyApiException('Belum ada data kurs yang valid.');
    }

    return List.unmodifiable(rates);
  }

  @override
  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:worthbang_lite/services/currency_api.dart';

void main() {
  group('CurrencyApi', () {
    test('mem-parse kurs populer dari respons HTTP 200', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), CurrencyApi.defaultEndpoint);
        return http.Response(
          jsonEncode({
            'result': 'success',
            'base_code': 'IDR',
            'rates': {
              'IDR': 1,
              'USD': 0.0000625,
              'SGD': 0.000084,
              'JPY': 0.0095,
              'ZZZ': 0.5,
            },
          }),
          200,
        );
      });

      final api = CurrencyApi(client: client);
      final rates = await api.fetchRates();

      expect(rates.map((r) => r.code).toList(), ['USD', 'SGD', 'JPY']);
      expect(rates.first.convertFromIdr(1600000), closeTo(100, 0.01));
    });

    test('tetap mem-parse mata uang lain jika daftar unggulan tidak ada', () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'rates': {'IDR': 1, 'CHF': 0.000055, 'CAD': 0.000085},
          }),
          200,
        );
      });

      final api = CurrencyApi(client: client);
      final rates = await api.fetchRates();

      expect(rates.map((r) => r.code).toSet(), {'CHF', 'CAD'});
    });

    test('melempar CurrencyApiException pada status HTTP 500', () async {
      final client = MockClient((_) async => http.Response('Server Error', 500));
      final api = CurrencyApi(client: client);

      await expectLater(
        api.fetchRates(),
        throwsA(
          isA<CurrencyApiException>().having(
            (e) => e.message,
            'message',
            contains('500'),
          ),
        ),
      );
    });

    test('melempar CurrencyApiException pada JSON rusak', () async {
      final client = MockClient((_) async => http.Response('{rusak', 200));
      final api = CurrencyApi(client: client);

      await expectLater(api.fetchRates(), throwsA(isA<CurrencyApiException>()));
    });

    test('melempar CurrencyApiException jika field rates tidak valid', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode({'result': 'success'}), 200),
      );
      final api = CurrencyApi(client: client);

      await expectLater(api.fetchRates(), throwsA(isA<CurrencyApiException>()));
    });

    test('melempar CurrencyApiException saat permintaan timeout', () async {
      final client = MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return http.Response('{}', 200);
      });
      final api = CurrencyApi(
        client: client,
        timeout: const Duration(milliseconds: 10),
      );

      await expectLater(
        api.fetchRates(),
        throwsA(
          isA<CurrencyApiException>().having(
            (e) => e.message,
            'message',
            contains('batas waktu'),
          ),
        ),
      );
    });
  });
}

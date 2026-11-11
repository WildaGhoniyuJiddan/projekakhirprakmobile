import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang_lite/models/location_snapshot.dart';

void main() {
  group('LocationSnapshot', () {
    test('coordinateLabel memformat lima desimal', () {
      final snapshot = LocationSnapshot(
        latitude: -6.2088,
        longitude: 106.8456,
        accuracyMeters: 12.5,
        capturedAt: DateTime(2026, 11, 11),
      );
      expect(snapshot.coordinateLabel, '-6.20880, 106.84560');
    });

    test('LocationException menampilkan pesan', () {
      const error = LocationException('Izin lokasi ditolak.');
      expect(error.toString(), 'Izin lokasi ditolak.');
    });
  });
}

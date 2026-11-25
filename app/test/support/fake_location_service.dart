import 'package:worthbang_lite/models/location_snapshot.dart';
import 'package:worthbang_lite/services/location_service.dart';

/// Lokasi palsu untuk test: sukses dengan koordinat tetap atau melempar error.
class FakeLocationService implements LocationService {
  FakeLocationService({
    LocationSnapshot? snapshot,
    this.error,
    this.serviceEnabled = true,
  }) : snapshot =
           snapshot ??
           LocationSnapshot(
             latitude: -6.2088,
             longitude: 106.8456,
             accuracyMeters: 12,
             capturedAt: DateTime(2026, 1, 1),
           );

  final LocationSnapshot snapshot;
  final Object? error;
  final bool serviceEnabled;

  int locateCalls = 0;
  int settingsCalls = 0;

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationSnapshot> getCurrentLocation() async {
    locateCalls++;
    final failure = error;
    if (failure != null) throw failure;
    return snapshot;
  }

  @override
  Future<bool> openAppSettings() async {
    settingsCalls++;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async => true;
}

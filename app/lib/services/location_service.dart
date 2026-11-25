import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/location_snapshot.dart';

/// Kontrak pengambilan lokasi perangkat (Modul 7 — LBS).
abstract class LocationService {
  Future<bool> isServiceEnabled();
  Future<LocationSnapshot> getCurrentLocation();
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}

/// Implementasi berbasis `geolocator` dengan alur izin yang eksplisit.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationSnapshot> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        'Aktifkan layanan lokasi/GPS terlebih dahulu.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Izin lokasi diblokir. Buka Pengaturan aplikasi untuk mengizinkannya.',
      );
    }
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      throw const LocationException(
        'Izin lokasi ditolak. Peta memakai lokasi demo Jakarta.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LocationSnapshot(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        capturedAt: DateTime.now(),
      );
    } on TimeoutException {
      throw const LocationException(
        'Lokasi belum ditemukan. Pastikan GPS aktif lalu coba lagi.',
      );
    } on LocationServiceDisabledException {
      throw const LocationException(
        'Layanan lokasi dimatikan saat pengambilan posisi.',
      );
    }
  }

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}

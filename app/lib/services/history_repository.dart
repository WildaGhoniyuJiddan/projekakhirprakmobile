import 'package:hive/hive.dart';

import '../models/price_analysis.dart';

/// Satu riwayat analisis beserta key Hive-nya.
///
/// Key disimpan agar penghapusan tetap tepat setelah item lain dihapus.
class HistoryRecord {
  const HistoryRecord({required this.key, required this.analysis});

  final int key;
  final PriceAnalysis analysis;
}

/// Riwayat ringan hasil cek harga di Hive.
///
/// Ini bukan hash chain/blockchain: hanya hash map JSON per hasil analisis.
class HistoryRepository {
  HistoryRepository(this._box);

  final Box<dynamic> _box;

  Future<int> add(PriceAnalysis analysis) => _box.add(analysis.toJson());

  /// Semua riwayat, terbaru lebih dulu. Data korup dilewati.
  List<HistoryRecord> getAll() {
    final records = <HistoryRecord>[];
    for (final key in _box.keys) {
      if (key is! int) continue;
      final raw = _box.get(key);
      if (raw is! Map) continue;
      try {
        records.add(
          HistoryRecord(
            key: key,
            analysis: PriceAnalysis.fromJson(Map<String, dynamic>.from(raw)),
          ),
        );
      } on Object {
        // Data lama yang tidak kompatibel tidak boleh menjatuhkan layar.
        continue;
      }
    }
    records.sort((a, b) => b.key.compareTo(a.key));
    return records;
  }

  List<HistoryRecord> recent({int limit = 3}) => getAll().take(limit).toList();

  Future<void> deleteAt(int index) => _box.deleteAt(index);

  int get length => _box.length;
}

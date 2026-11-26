import 'package:intl/intl.dart';

final NumberFormat _rupiahFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);

DateFormat? _dateFormatterId;
final DateFormat _dateFormatterFallback = DateFormat('d MMM yyyy HH:mm');

/// Format integer IDR ke Rupiah Indonesia, mis. 4500000 -> "Rp4.500.000".
String formatRupiah(int amount) => _rupiahFormatter.format(amount);

/// Format jarak kilometer untuk daftar toko.
String formatDistance(double km) {
  if (km < 1) return '${(km * 1000).round()} m';
  return '${km.toStringAsFixed(1)} km';
}

/// Format tanggal ringkas Bahasa Indonesia.
String formatDate(DateTime date) {
  try {
    _dateFormatterId ??= DateFormat('d MMM yyyy HH:mm', 'id_ID');
    return _dateFormatterId!.format(date);
  } on Object {
    return _dateFormatterFallback.format(date);
  }
}

/// Label kondisi komponen yang ramah pengguna.
String formatCondition(String condition) => switch (condition) {
  'baru' => 'Baru',
  'bekas' => 'Bekas',
  'any' => 'Semua kondisi',
  _ => condition,
};

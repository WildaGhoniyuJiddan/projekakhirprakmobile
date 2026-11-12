import 'package:intl/intl.dart';

/// Format integer IDR ke Rupiah Indonesia, mis. 4500000 -> "Rp4.500.000".
String formatRupiah(int amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

/// Format jarak kilometer untuk daftar toko.
String formatDistance(double km) {
  if (km < 1) return '${(km * 1000).round()} m';
  return '${km.toStringAsFixed(1)} km';
}

/// Format tanggal ringkas Bahasa Indonesia.
String formatDate(DateTime date) =>
    DateFormat('d MMM yyyy HH:mm', 'id_ID').format(date);

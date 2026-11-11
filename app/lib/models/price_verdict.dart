import 'package:flutter/material.dart';

/// Kontrak verdict harga.
///
/// Setiap subclass menampilkan label, warna, ikon, dan saran yang berbeda.
/// Ini adalah bukti inheritance + polymorphism yang dipakai langsung oleh UI.
abstract class PriceVerdict {
  const PriceVerdict();

  /// Kunci stabil untuk penyimpanan (Hive/JSON).
  String get key;

  String get label;
  Color get color;
  IconData get icon;
  String get advice;

  /// Bobot visual badge; subclass boleh meng-override.
  double get emphasis => 1.0;

  /// Rekonstruksi verdict dari data tersimpan.
  static PriceVerdict fromKey(String? key) {
    return switch (key) {
      'worth_it' || 'worth it' => const WorthItVerdict(),
      'overpriced' || 'kemahalan' => const OverpricedVerdict(),
      'limited' || 'data terbatas' => const LimitedDataVerdict(),
      _ => const FairVerdict(),
    };
  }
}

class WorthItVerdict extends PriceVerdict {
  const WorthItVerdict();

  @override
  String get key => 'worth_it';

  @override
  String get label => 'Worth It';

  @override
  Color get color => const Color(0xFF4ADE80);

  @override
  IconData get icon => Icons.thumb_up_alt_rounded;

  @override
  String get advice => 'Harga di bawah median pasar. Layak dipertimbangkan.';
}

class FairVerdict extends PriceVerdict {
  const FairVerdict();

  @override
  String get key => 'fair';

  @override
  String get label => 'Wajar';

  @override
  Color get color => const Color(0xFFFBBF24);

  @override
  IconData get icon => Icons.balance_rounded;

  @override
  String get advice => 'Harga masih dalam rentang wajar pasar.';
}

class OverpricedVerdict extends PriceVerdict {
  const OverpricedVerdict();

  @override
  String get key => 'overpriced';

  @override
  String get label => 'Kemahalan';

  @override
  Color get color => const Color(0xFFF87171);

  @override
  IconData get icon => Icons.trending_up_rounded;

  @override
  String get advice =>
      'Harga di atas median. Coba negosiasi atau cari opsi lain.';

  @override
  double get emphasis => 1.2;
}

class LimitedDataVerdict extends PriceVerdict {
  const LimitedDataVerdict();

  @override
  String get key => 'limited';

  @override
  String get label => 'Data Terbatas';

  @override
  Color get color => const Color(0xFF94A3B8);

  @override
  IconData get icon => Icons.help_outline_rounded;

  @override
  String get advice => 'Belum cukup pembanding untuk verdict kuat.';
}

/// Validator form yang dipakai lintas layar.
abstract final class AppValidators {
  static String? query(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Nama produk minimal 2 karakter.';
    }
    return null;
  }

  static String? price(String? value) {
    final digits = int.tryParse(
      (value ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
    );
    if (digits == null || digits <= 0) {
      return 'Masukkan harga yang valid.';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 8) {
      return 'Kata sandi minimal 8 karakter.';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama wajib diisi.';
    }
    return null;
  }
}

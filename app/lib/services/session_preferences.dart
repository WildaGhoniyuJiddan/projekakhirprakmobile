import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper SharedPreferences untuk sesi login dan preferensi tema.
///
/// Semua akses key-value Modul 6 lewat kelas ini agar tidak ada pemanggilan
/// `SharedPreferences.getInstance()` berulang di widget.
class SessionPreferences {
  SessionPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kLoggedIn = 'is_logged_in';
  static const _kEmail = 'active_email';
  static const _kTheme = 'theme_mode';

  bool get isLoggedIn => _prefs.getBool(_kLoggedIn) ?? false;
  String? get activeEmail => _prefs.getString(_kEmail);

  Future<void> saveSession({required String email}) async {
    await _prefs.setBool(_kLoggedIn, true);
    await _prefs.setString(_kEmail, email);
  }

  Future<void> clearSession() async {
    await _prefs.setBool(_kLoggedIn, false);
    await _prefs.remove(_kEmail);
  }

  String get themeMode => _prefs.getString(_kTheme) ?? 'dark';

  Future<void> saveThemeMode(String mode) => _prefs.setString(_kTheme, mode);
}

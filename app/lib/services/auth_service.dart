import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';

import '../core/utils/validators.dart';
import '../models/user_account.dart';
import 'session_preferences.dart';

/// Kegagalan domain autentikasi yang aman ditampilkan ke pengguna.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Autentikasi lokal: akun disimpan di Hive, sesi di SharedPreferences.
///
/// Kata sandi tidak pernah disimpan mentah. Setiap akun punya salt acak dan
/// hash SHA-256 dari `salt::password`.
class AuthService {
  AuthService(this._accountsBox, this._prefs);

  final Box<dynamic> _accountsBox;
  final SessionPreferences _prefs;

  Future<UserAccount> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final nameError = AppValidators.name(name);
    if (nameError != null) throw AuthException(nameError);

    final emailError = AppValidators.email(email);
    if (emailError != null) throw AuthException(emailError);

    _validatePassword(password);

    final account = UserAccount(id: _nextId(), name: name, email: email);

    if (_accountsBox.containsKey(account.email)) {
      throw const AuthException('Email sudah terdaftar. Silakan masuk.');
    }

    final salt = _createSalt();
    await _accountsBox.put(account.email, {
      ...account.toMap(),
      'password_hash': _hashPassword(password, salt),
      'salt': salt,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _prefs.saveSession(email: account.email);
    return account;
  }

  Future<UserAccount> login({
    required String email,
    required String password,
  }) async {
    final emailError = AppValidators.email(email);
    if (emailError != null) throw AuthException(emailError);

    final normalizedEmail = email.trim().toLowerCase();
    final raw = _accountsBox.get(normalizedEmail);
    if (raw is! Map) {
      throw const AuthException('Email belum terdaftar.');
    }

    final stored = Map<String, dynamic>.from(raw);
    final salt = stored['salt'] as String? ?? '';
    final storedHash = stored['password_hash'] as String? ?? '';
    if (salt.isEmpty || storedHash != _hashPassword(password, salt)) {
      throw const AuthException('Email atau kata sandi salah.');
    }

    final account = UserAccount.fromMap(stored);
    await _prefs.saveSession(email: account.email);
    return account;
  }

  /// Memulihkan sesi saat aplikasi dibuka kembali.
  Future<UserAccount?> restoreSession() async {
    if (!_prefs.isLoggedIn) return null;

    final email = _prefs.activeEmail;
    if (email == null) {
      await _prefs.clearSession();
      return null;
    }

    final raw = _accountsBox.get(email);
    if (raw is! Map) {
      await _prefs.clearSession();
      return null;
    }

    try {
      return UserAccount.fromMap(Map<String, dynamic>.from(raw));
    } on ArgumentError {
      await _prefs.clearSession();
      return null;
    }
  }

  Future<void> logout() => _prefs.clearSession();

  void _validatePassword(String value) {
    final error = AppValidators.password(value);
    if (error != null) throw AuthException(error);
  }

  int _nextId() {
    var maxId = 0;
    for (final value in _accountsBox.values) {
      if (value is Map) {
        final id = (value['id'] as num?)?.toInt() ?? 0;
        if (id > maxId) maxId = id;
      }
    }
    return maxId + 1;
  }

  static String _createSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String _hashPassword(String password, String salt) =>
      sha256.convert(utf8.encode('$salt::$password')).toString();
}

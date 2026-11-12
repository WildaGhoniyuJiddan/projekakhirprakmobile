import 'package:flutter/foundation.dart';

import '../models/user_account.dart';
import '../services/auth_service.dart';

/// State sesi login yang berlaku di seluruh aplikasi.
class SessionController extends ChangeNotifier {
  SessionController(this._auth);

  final AuthService _auth;

  UserAccount? _user;
  bool _restoring = true;

  UserAccount? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isRestoring => _restoring;

  /// Dipanggil saat bootstrap untuk memulihkan sesi dari SharedPreferences.
  Future<void> restore() async {
    _restoring = true;
    notifyListeners();
    try {
      _user = await _auth.restoreSession();
    } on AuthException {
      _user = null;
    } finally {
      _restoring = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    _user = await _auth.login(email: email, password: password);
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _user = await _auth.register(name: name, email: email, password: password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    _user = null;
    notifyListeners();
  }
}

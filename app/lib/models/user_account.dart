/// Akun pengguna lokal.
class UserAccount {
  UserAccount({
    required int id,
    required String name,
    required String email,
    String? avatarUrl,
  }) : _id = id < 0 ? 0 : id,
       _name = _validateName(name),
       _email = _validateEmail(email),
       // ignore: prefer_initializing_formals — parameter publik, field privat.
       _avatarUrl = avatarUrl;

  /// Redirecting constructor: tampilan tamu sebelum login.
  UserAccount.empty()
    : this(id: 0, name: 'Tamu', email: 'tamu@worthbang.local');

  /// Named constructor: dari Map Hive/backup.
  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  final int _id;
  String _name;
  String _email;
  String? _avatarUrl;

  int get id => _id;
  String get name => _name;
  String get email => _email;

  set name(String value) => _name = _validateName(value);
  set email(String value) => _email = _validateEmail(value);
  set avatarUrl(String? value) => _avatarUrl = value;

  String get avatarUrl =>
      _avatarUrl ??
      'https://i.pravatar.cc/160?u=${Uri.encodeComponent(_email)}';

  Map<String, dynamic> toMap() => {
    'id': _id,
    'name': _name,
    'email': _email,
    'avatar_url': _avatarUrl,
  };

  static String _validateName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Nama tidak boleh kosong.');
    }
    return trimmed;
  }

  static String _validateEmail(String value) {
    final trimmed = value.trim().toLowerCase();
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
    if (!valid) {
      throw ArgumentError('Format email tidak valid.');
    }
    return trimmed;
  }
}

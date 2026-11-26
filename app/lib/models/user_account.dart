/// Akun pengguna lokal.
class UserAccount {
  UserAccount({
    required int id,
    required String name,
    required String email,
    this.avatarUrl,
  }) : _id = id < 0 ? 0 : id,
       _name = _validateName(name),
       _email = _validateEmail(email);

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
  String? avatarUrl;

  int get id => _id;
  String get name => _name;
  String get email => _email;

  set name(String value) => _name = _validateName(value);
  set email(String value) => _email = _validateEmail(value);

  /// Inisial nama pengguna untuk avatar lokal (mis. "Budi Santoso" -> "BS").
  String get initials {
    final parts = _name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Map<String, dynamic> toMap() => {
    'id': _id,
    'name': _name,
    'email': _email,
    'avatar_url': avatarUrl,
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

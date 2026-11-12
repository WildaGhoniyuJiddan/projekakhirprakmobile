import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/utils/validators.dart';
import '../core/widgets/monex_widgets.dart';
import '../services/auth_service.dart';
import '../state/app_scope.dart';
import '../widgets/app_logo.dart';
import '../widgets/auth_error_banner.dart';
import 'register_screen.dart';
import 'root_screen.dart';

/// Login lokal dengan validasi form dan umpan balik error.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialEmail = ''});

  /// Diisi saat pengguna kembali dari layar register.
  final String initialEmail;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );
  final TextEditingController _password = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AppScope.of(context).sessionController
          .login(email: _email.text, password: _password.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const RootScreen()),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Login gagal. Coba lagi.';
      });
    }
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegisterScreen(initialEmail: _email.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              MonexSpacing.screenPaddingH,
              32,
              MonexSpacing.screenPaddingH,
              32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: AppLogo(size: 76, borderRadius: 20)),
                      const SizedBox(height: 22),
                      Text(
                        'Masuk ke WorthBang',
                        style: theme.textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lanjutkan cek harga dan wishlist yang tersimpan di '
                        'perangkat ini.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        key: const Key('login_email'),
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'nama@email.com',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                        validator: AppValidators.email,
                      ),
                      const SizedBox(height: MonexSpacing.gridGap),
                      TextFormField(
                        key: const Key('login_password'),
                        controller: _password,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Kata sandi',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _obscure
                                ? 'Tampilkan kata sandi'
                                : 'Sembunyikan kata sandi',
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: AppValidators.password,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: MonexSpacing.gridGap),
                        AuthErrorBanner(message: _error!),
                      ],
                      const SizedBox(height: MonexSpacing.sectionGap + 6),
                      MonexPrimaryButton(
                        key: const Key('login_submit'),
                        label: 'Masuk',
                        icon: Icons.login_rounded,
                        loading: _loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun?',
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            key: const Key('login_register_link'),
                            onPressed: _loading ? null : _openRegister,
                            child: const Text('Daftar di sini'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Akun disimpan lokal. Tidak ada data yang dikirim ke server.',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

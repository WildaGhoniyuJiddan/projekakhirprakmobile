import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/utils/validators.dart';
import '../core/widgets/monex_widgets.dart';
import '../services/auth_service.dart';
import '../state/app_scope.dart';
import '../widgets/auth_error_banner.dart';
import 'root_screen.dart';

/// Pendaftaran akun lokal; sesi langsung aktif setelah berhasil.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
      await AppScope.of(context).sessionController.register(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const RootScreen()),
        (route) => false,
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
        _error = 'Pendaftaran gagal. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Buat Akun'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            MonexSpacing.screenPaddingH,
            MonexSpacing.screenPaddingV,
            MonexSpacing.screenPaddingH,
            32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Satu akun untuk menyimpan wishlist dan riwayat di perangkat ini.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: MonexSpacing.sectionGap),
                TextFormField(
                  key: const Key('register_name'),
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    hintText: 'Nama panggilan',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: AppValidators.name,
                ),
                const SizedBox(height: MonexSpacing.gridGap),
                TextFormField(
                  key: const Key('register_email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'nama@email.com',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  validator: AppValidators.email,
                ),
                const SizedBox(height: MonexSpacing.gridGap),
                TextFormField(
                  key: const Key('register_password'),
                  controller: _password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Kata sandi',
                    hintText: 'Minimal 8 karakter',
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
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: AppValidators.password,
                ),
                const SizedBox(height: MonexSpacing.gridGap),
                TextFormField(
                  key: const Key('register_confirm'),
                  controller: _confirm,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Ulangi kata sandi',
                    prefixIcon: Icon(Icons.lock_reset_rounded),
                  ),
                  validator: (value) =>
                      AppValidators.confirmPassword(value, _password.text),
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: MonexSpacing.gridGap),
                  AuthErrorBanner(message: _error!),
                ],
                const SizedBox(height: MonexSpacing.sectionGap + 6),
                MonexPrimaryButton(
                  key: const Key('register_submit'),
                  label: 'Daftar dan Masuk',
                  icon: Icons.person_add_alt_1_rounded,
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                Text(
                  'Kata sandi di-hash sebelum disimpan. Tidak ada unggahan ke server.',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

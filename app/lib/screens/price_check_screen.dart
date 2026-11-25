import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/utils/validators.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/price_check_request.dart';
import '../state/app_scope.dart';
import '../widgets/auth_error_banner.dart';
import 'result_screen.dart';

/// Form Cek Harga yang terhubung ke [PriceAnalyzer] dan [HistoryRepository].
class PriceCheckScreen extends StatefulWidget {
  const PriceCheckScreen({
    super.key,
    this.initialQuery = '',
    this.initialPrice,
    this.initialCondition = 'baru',
  });

  final String initialQuery;
  final int? initialPrice;
  final String initialCondition;

  @override
  State<PriceCheckScreen> createState() => _PriceCheckScreenState();
}

class _PriceCheckScreenState extends State<PriceCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _query = TextEditingController(
    text: widget.initialQuery,
  );
  late final TextEditingController _price = TextEditingController(
    text: widget.initialPrice != null && widget.initialPrice! > 0
        ? widget.initialPrice.toString()
        : '',
  );

  late String _condition = widget.initialCondition;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _query.dispose();
    _price.dispose();
    super.dispose();
  }

  int _parsePrice(String raw) {
    return int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    final scope = AppScope.of(context);
    try {
      final request = PriceCheckRequest(
        query: _query.text,
        price: _parsePrice(_price.text),
        condition: _condition,
      );
      final analysis = await scope.priceAnalyzer.analyze(request);

      try {
        await scope.historyRepository.add(analysis);
      } on Object {
        // Kegagalan simpan riwayat tidak memblokir tampilan hasil.
      }

      if (!mounted) return;
      setState(() => _loading = false);

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(analysis: analysis),
        ),
      );
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal menganalisis harga. Periksa input dan coba lagi.';
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
        title: const Text('Cek Harga'),
        actions: [
          IconButton(
            tooltip: 'Info',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (context) => const _InfoSheet(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            MonexSpacing.screenPaddingH,
            MonexSpacing.screenPaddingV,
            MonexSpacing.screenPaddingH,
            24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Masukkan komponen dan harga yang ditawarkan.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: MonexSpacing.sectionGap),
                TextFormField(
                  key: const Key('price_check_query'),
                  controller: _query,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama produk',
                    hintText: 'cth: RTX 4060',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  validator: AppValidators.query,
                ),
                const SizedBox(height: MonexSpacing.gridGap),
                TextFormField(
                  key: const Key('price_check_price'),
                  controller: _price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga yang ditawarkan',
                    prefixText: 'Rp ',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: AppValidators.price,
                ),
                const SizedBox(height: MonexSpacing.gridGap),
                DropdownButtonFormField<String>(
                  initialValue: _condition,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Kondisi',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'baru', child: Text('Baru')),
                    DropdownMenuItem(value: 'bekas', child: Text('Bekas')),
                    DropdownMenuItem(
                      value: 'any',
                      child: Text('Semua kondisi'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _condition = value ?? 'baru'),
                ),
                const SizedBox(height: MonexSpacing.sectionGap + 6),
                if (_error != null) ...[
                  AuthErrorBanner(message: _error!),
                  const SizedBox(height: MonexSpacing.gridGap),
                ],
                MonexPrimaryButton(
                  key: const Key('price_check_submit'),
                  label: 'Cek Kelayakan',
                  icon: Icons.analytics_outlined,
                  loading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSheet extends StatelessWidget {
  const _InfoSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cek Harga', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Harga yang Anda masukkan dibandingkan dengan median seri yang '
            'cocok di katalog retail. Rentang wajar berada pada ±10% dari '
            'median pasar.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          MonexPrimaryButton(
            label: 'Mengerti',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

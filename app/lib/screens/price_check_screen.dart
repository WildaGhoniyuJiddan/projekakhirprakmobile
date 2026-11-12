import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/utils/formatters.dart';
import '../core/utils/validators.dart';
import '../core/widgets/monex_widgets.dart';

/// Kerangka form Cek Harga.
///
/// Validasi dan passing input sudah aktif; mesin analisis katalog
/// dihubungkan pada Phase 3.
class PriceCheckScreen extends StatefulWidget {
  const PriceCheckScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<PriceCheckScreen> createState() => _PriceCheckScreenState();
}

class _PriceCheckScreenState extends State<PriceCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _query = TextEditingController(
    text: widget.initialQuery,
  );
  final TextEditingController _price = TextEditingController();

  String _condition = 'baru';
  bool _submitted = false;
  int _parsedPrice = 0;

  @override
  void dispose() {
    _query.dispose();
    _price.dispose();
    super.dispose();
  }

  int _parsePrice(String raw) {
    return int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _submitted = false);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _submitted = true;
      _parsedPrice = _parsePrice(_price.text);
    });
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
                MonexPrimaryButton(
                  label: 'Cek Kelayakan',
                  icon: Icons.analytics_outlined,
                  onPressed: _submit,
                ),
                if (_submitted) ...[
                  const SizedBox(height: MonexSpacing.sectionGap),
                  MonexSurfaceCard(
                    padding: const EdgeInsets.all(MonexSpacing.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: MonexColors.lime,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Input valid',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Produk: ${_query.text.trim()}'),
                        Text('Harga: ${formatRupiah(_parsedPrice)}'),
                        Text('Kondisi: $_condition'),
                        const SizedBox(height: 10),
                        Text(
                          'Mesin analisis katalog dan verdict akan dihubungkan '
                          'pada Phase 3.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
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
            'Form ini adalah kerangka. Validasi input sudah aktif; '
            'perhitungan median, skor, dan verdict akan memakai katalog '
            'retail pada Phase 3.',
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

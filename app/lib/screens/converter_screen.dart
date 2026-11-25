import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/theme/monex_theme.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/currency_rate.dart';
import '../services/currency_api.dart';
import '../state/app_scope.dart';

/// Konverter mata uang dari IDR ke mata uang asing berbasis kurs HTTP publik.
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key, this.initialAmountIdr = 5000000});

  final int initialAmountIdr;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  static const _presets = <int>[1000000, 5000000, 10000000, 20000000];

  late final TextEditingController _amountController;
  List<CurrencyRate> _rates = const [];
  String _selectedCode = 'USD';
  bool _isLoading = true;
  String? _error;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmountIdr > 0
          ? widget.initialAmountIdr.toString()
          : '5000000',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _loadRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int get _amountIdr {
    final digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  CurrencyRate? get _selectedRate {
    if (_rates.isEmpty) return null;
    for (final rate in _rates) {
      if (rate.code == _selectedCode) return rate;
    }
    return _rates.first;
  }

  Future<void> _loadRates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rates = await AppScope.of(context).currencyService.fetchRates();
      if (!mounted) return;
      setState(() {
        _rates = rates;
        if (rates.isNotEmpty && !rates.any((r) => r.code == _selectedCode)) {
          _selectedCode = rates.first.code;
        }
        _isLoading = false;
      });
    } on CurrencyApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _isLoading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat kurs mata uang. Coba lagi beberapa saat.';
        _isLoading = false;
      });
    }
  }

  void _applyPreset(int amount) {
    _amountController.text = amount.toString();
    _amountController.selection = TextSelection.collapsed(
      offset: _amountController.text.length,
    );
    setState(() {});
  }

  String _formatForeign(CurrencyRate rate, int amountIdr) {
    final converted = rate.convertFromIdr(amountIdr.toDouble());
    final zeroDecimal = rate.code == 'JPY' || rate.code == 'KRW';
    final formatter = NumberFormat.decimalPatternDigits(
      locale: 'id_ID',
      decimalDigits: zeroDecimal ? 0 : 2,
    );
    return '${formatter.format(converted)} ${rate.code}';
  }

  String _formatIdrPerUnit(CurrencyRate rate) {
    if (rate.rate <= 0) return '-';
    final idrPerUnit = (1 / rate.rate).round();
    return '1 ${rate.code} ≈ ${formatRupiah(idrPerUnit)}';
  }

  String _currencyName(String code) => switch (code) {
    'USD' => 'Dolar Amerika Serikat',
    'SGD' => 'Dolar Singapura',
    'JPY' => 'Yen Jepang',
    'EUR' => 'Euro',
    'MYR' => 'Ringgit Malaysia',
    'CNY' => 'Yuan Tiongkok',
    'AUD' => 'Dolar Australia',
    'GBP' => 'Poundsterling Inggris',
    'KRW' => 'Won Korea Selatan',
    'TWD' => 'Dolar Taiwan Baru',
    _ => code,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountIdr = _amountIdr;
    final selected = _selectedRate;

    return Scaffold(
      appBar: MonexAppBar(
        title: 'Konverter Kurs',
        subtitle: 'Konversi harga IDR ke mata uang asing',
        showBack: true,
        actions: [
          IconButton(
            key: const Key('converter_refresh'),
            tooltip: 'Muat ulang kurs',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _loadRates,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MonexSpacing.screenPaddingH,
                MonexSpacing.screenPaddingV,
                MonexSpacing.screenPaddingH,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MonexSurfaceCard(
                    padding: const EdgeInsets.all(MonexSpacing.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nominal Rupiah (IDR)',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          key: const Key('converter_amount'),
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            prefixText: 'Rp ',
                            hintText: '5000000',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final preset in _presets)
                              ActionChip(
                                label: Text('${preset ~/ 1000000} Jt'),
                                onPressed: () => _applyPreset(preset),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (selected != null && !_isLoading && _error == null) ...[
                    const SizedBox(height: MonexSpacing.gridGap),
                    MonexGradientCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${formatRupiah(amountIdr)} setara dengan',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: MonexColors.textDark.withValues(
                                alpha: 0.75,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            key: const Key('converter_highlight_value'),
                            _formatForeign(selected, amountIdr),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: MonexColors.textDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_currencyName(selected.code)} · ${_formatIdrPerUnit(selected)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: MonexColors.textDark.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: MonexSpacing.gridGap),
            Expanded(child: _buildBody(theme, amountIdr)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, int amountIdr) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text('Memuat kurs terbaru...', style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MonexSpacing.screenPaddingH,
        ),
        child: MonexEmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Kurs belum bisa dimuat',
          message: _error!,
          actionLabel: 'Coba lagi',
          onAction: _loadRates,
        ),
      );
    }

    if (_rates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MonexSpacing.screenPaddingH,
        ),
        child: MonexEmptyState(
          icon: Icons.currency_exchange_rounded,
          title: 'Data kurs kosong',
          message: 'Tidak ada mata uang yang dapat ditampilkan saat ini.',
          actionLabel: 'Muat ulang',
          onAction: _loadRates,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        MonexSpacing.screenPaddingH,
        0,
        MonexSpacing.screenPaddingH,
        24,
      ),
      itemCount: _rates.length,
      itemBuilder: (context, index) {
        final rate = _rates[index];
        final isSelected = rate.code == _selectedCode;
        return Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : MonexSpacing.gridGap),
          child: MonexSurfaceCard(
            key: Key('currency_tile_${rate.code}'),
            onTap: () => setState(() => _selectedCode = rate.code),
            borderColor: isSelected
                ? MonexColors.lime.withValues(alpha: 0.6)
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            radius: MonexSpacing.radiusMd,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MonexColors.lime
                        : MonexColors.limeMuted,
                    borderRadius: BorderRadius.circular(MonexSpacing.radiusSm),
                  ),
                  child: Text(
                    rate.code,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? MonexColors.textDark
                          : MonexColors.lime,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currencyName(rate.code),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatIdrPerUnit(rate),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _formatForeign(rate, amountIdr),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: MonexColors.lime,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

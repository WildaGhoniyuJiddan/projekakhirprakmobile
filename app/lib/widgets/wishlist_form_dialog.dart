import 'package:flutter/material.dart';

import '../core/theme/monex_theme.dart';
import '../core/utils/validators.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/wishlist_item.dart';

/// Dialog form untuk menambah atau mengubah item wishlist.
///
/// Mengembalikan [WishlistItem] saat disubmit, atau `null` jika dibatalkan.
class WishlistFormDialog extends StatefulWidget {
  const WishlistFormDialog({
    super.key,
    this.initialItem,
    this.initialQuery = '',
    this.initialTargetPrice,
    this.initialCondition = 'baru',
  });

  final WishlistItem? initialItem;
  final String initialQuery;
  final int? initialTargetPrice;
  final String initialCondition;

  static Future<WishlistItem?> show(
    BuildContext context, {
    WishlistItem? initialItem,
    String initialQuery = '',
    int? initialTargetPrice,
    String initialCondition = 'baru',
  }) {
    return showDialog<WishlistItem>(
      context: context,
      builder: (_) => WishlistFormDialog(
        initialItem: initialItem,
        initialQuery: initialQuery,
        initialTargetPrice: initialTargetPrice,
        initialCondition: initialCondition,
      ),
    );
  }

  @override
  State<WishlistFormDialog> createState() => _WishlistFormDialogState();
}

class _WishlistFormDialogState extends State<WishlistFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _queryController = TextEditingController(
    text: widget.initialItem?.query ?? widget.initialQuery,
  );
  late final TextEditingController _priceController = TextEditingController(
    text: _initialPriceText(),
  );
  late String _condition =
      widget.initialItem?.condition ?? widget.initialCondition;

  bool get _isEditing => widget.initialItem != null;

  String _initialPriceText() {
    final price = widget.initialItem?.targetPrice ?? widget.initialTargetPrice;
    return price != null && price > 0 ? price.toString() : '';
  }

  @override
  void dispose() {
    _queryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  int _parsePrice(String raw) =>
      int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final item = WishlistItem(
      query: _queryController.text.trim(),
      targetPrice: _parsePrice(_priceController.text),
      condition: _condition,
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Ubah Wishlist' : 'Tambah Wishlist'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('wishlist_form_query'),
                controller: _queryController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama komponen',
                  hintText: 'cth: RTX 4060',
                  prefixIcon: Icon(Icons.memory_rounded),
                ),
                validator: AppValidators.query,
              ),
              const SizedBox(height: MonexSpacing.gridGap),
              TextFormField(
                key: const Key('wishlist_form_price'),
                controller: _priceController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Target harga',
                  prefixText: 'Rp ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: AppValidators.price,
              ),
              const SizedBox(height: MonexSpacing.gridGap),
              DropdownButtonFormField<String>(
                key: const Key('wishlist_form_condition'),
                initialValue: _condition,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Kondisi',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'baru', child: Text('Baru')),
                  DropdownMenuItem(value: 'bekas', child: Text('Bekas')),
                  DropdownMenuItem(value: 'any', child: Text('Semua kondisi')),
                ],
                onChanged: (value) =>
                    setState(() => _condition = value ?? 'baru'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        MonexPrimaryButton(
          key: const Key('wishlist_form_submit'),
          label: _isEditing ? 'Simpan' : 'Tambah',
          expanded: false,
          onPressed: _submit,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mochi_stok/core/format.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/data/inventory_store.dart';
import 'package:mochi_stok/models/item.dart';
import 'package:mochi_stok/widgets/form_widgets.dart';

/// Form tambah/ubah item (bottom sheet).
/// Saat selesai, sheet menutup dan mengembalikan (pesan, jenis item).
class ItemFormSheet extends StatefulWidget {
  const ItemFormSheet({
    super.key,
    required this.store,
    required this.initialType,
    this.item,
  });

  final InventoryStore store;
  final ItemType initialType;
  // null = mode tambah, ada isi = mode ubah.
  final Item? item;

  @override
  State<ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _unit;
  late final TextEditingController _stock;
  late final TextEditingController _minimum;
  late ItemType _type;
  bool _confirmDelete = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _type = item?.type ?? widget.initialType;
    _name = TextEditingController(text: item?.name ?? '');
    _unit = TextEditingController(
      text: item?.unit ?? (_type == ItemType.bahan ? 'kg' : 'pcs'),
    );
    _stock = TextEditingController(
      text: item == null ? '' : formatNumber(item.stock),
    );
    _minimum = TextEditingController(
      text: item == null ? '' : formatNumber(item.minimum),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    _stock.dispose();
    _minimum.dispose();
    super.dispose();
  }

  void _changeType(ItemType type) {
    setState(() {
      _type = type;
      // Satuan otomatis ikut berubah selama belum diubah manual.
      if (!_isEdit && (_unit.text == 'kg' || _unit.text == 'pcs')) {
        _unit.text = type == ItemType.bahan ? 'kg' : 'pcs';
      }
    });
  }

  String? _validateNumber(String? value, String label) {
    final number = parseNumber(value ?? '');
    if (number == null || number < 0) {
      return '$label harus berupa angka 0 atau lebih.';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final name = _name.text.trim();
    final unit = _unit.text.trim();
    final stock = parseNumber(_stock.text)!;
    final minimum = parseNumber(_minimum.text)!;

    if (_isEdit) {
      widget.store.updateItem(widget.item!.copyWith(
        name: name,
        type: _type,
        unit: unit,
        stock: stock,
        minimum: minimum,
      ));
      Navigator.of(context).pop(('Perubahan disimpan', _type));
    } else {
      widget.store.addItem(
        name: name,
        type: _type,
        unit: unit,
        stock: stock,
        minimum: minimum,
      );
      Navigator.of(context).pop(('Item ditambahkan', _type));
    }
  }

  void _delete() {
    final item = widget.item!;
    widget.store.deleteItem(item.id);
    Navigator.of(context).pop(('"${item.name}" dihapus', item.type));
  }

  @override
  Widget build(BuildContext context) {
    final decimalFormatter = FilteringTextInputFormatter.allow(
      RegExp(r'[0-9.,]'),
    );

    return Padding(
      // Sheet naik mengikuti keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEdit ? 'Ubah item' : 'Tambah item',
                style: const TextStyle(
                  color: MochiTheme.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              const FieldLabel('Nama'),
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: 'Contoh: Mochi durian'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama item wajib diisi.' : null,
              ),
              const SizedBox(height: 12),
              MochiSegmented<ItemType>(
                options: {for (final t in ItemType.values) t: t.label},
                value: _type,
                onChanged: _changeType,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Satuan'),
                        TextFormField(
                          controller: _unit,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(hintText: 'kg / pcs'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Satuan wajib diisi.'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Stok'),
                        TextFormField(
                          controller: _stock,
                          textInputAction: TextInputAction.next,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [decimalFormatter],
                          decoration: const InputDecoration(hintText: '0'),
                          validator: (v) => _validateNumber(v, 'Stok'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const FieldLabel('Batas minimum (peringatan muncul di bawah angka ini)'),
              TextFormField(
                controller: _minimum,
                textInputAction: TextInputAction.done,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [decimalFormatter],
                decoration: const InputDecoration(hintText: '0'),
                validator: (v) => _validateNumber(v, 'Batas minimum'),
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 18),
              FilledButton(onPressed: _save, child: const Text('Simpan')),
              if (_isEdit) ...[
                const SizedBox(height: 8),
                // Hapus butuh dua kali ketuk agar tidak terhapus tak sengaja.
                _confirmDelete
                    ? FilledButton(
                        onPressed: _delete,
                        child: const Text('Ya, hapus item ini'),
                      )
                    : OutlinedButton(
                        onPressed: () => setState(() => _confirmDelete = true),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          foregroundColor: MochiTheme.primary,
                          side: const BorderSide(color: MochiTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Hapus item'),
                      ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: MochiTheme.muted),
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

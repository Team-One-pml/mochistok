import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mochi_stok/core/format.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/data/inventory_store.dart';
import 'package:mochi_stok/models/category.dart';
import 'package:mochi_stok/models/item.dart';
import 'package:mochi_stok/widgets/form_widgets.dart';

/// Form tambah/ubah item bahan baku (bottom sheet).
class ItemFormSheet extends StatefulWidget {
  const ItemFormSheet({
    super.key,
    required this.store,
    this.initialCategoryId,
    this.item,
  });

  final InventoryStore store;
  final int? initialCategoryId;
  final Item? item;

  @override
  State<ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _sku;
  late final TextEditingController _name;
  late final TextEditingController _unit;
  late final TextEditingController _stock;
  late final TextEditingController _minimum;
  late int _categoryId;
  bool _confirmDelete = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _categoryId = item?.categoryId ??
        widget.initialCategoryId ??
        (widget.store.categories.isNotEmpty ? widget.store.categories.first.id : 1);
    _sku = TextEditingController(text: item?.sku ?? '');
    _name = TextEditingController(text: item?.name ?? '');
    _unit = TextEditingController(text: item?.unit ?? 'kg');
    _stock = TextEditingController(
      text: item == null ? '' : formatNumber(item.stock),
    );
    _minimum = TextEditingController(
      text: item == null ? '' : formatNumber(item.minimum),
    );
  }

  @override
  void dispose() {
    _sku.dispose();
    _name.dispose();
    _unit.dispose();
    _stock.dispose();
    _minimum.dispose();
    super.dispose();
  }

  String? _validateNumber(String? value, String label) {
    final number = parseNumber(value ?? '');
    if (number == null || number < 0) {
      return '$label harus berupa angka 0 atau lebih.';
    }
    return null;
  }

  Future<void> _dialogAddCategory() async {
    final catController = TextEditingController();
    final newCat = await showDialog<Category?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Kategori Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: catController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Contoh: Kemasan Khusus / Pewarna',
            labelText: 'Nama Kategori',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final text = catController.text.trim();
              if (text.isEmpty) return;
              final created = widget.store.addCategory(text);
              Navigator.pop(ctx, created);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (newCat != null && mounted) {
      setState(() {
        _categoryId = newCat.id;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final sku = _sku.text.trim();
    final name = _name.text.trim();
    final unit = _unit.text.trim();
    final stock = parseNumber(_stock.text)!;
    final minimum = parseNumber(_minimum.text)!;

    final cat = widget.store.findCategoryById(_categoryId);
    final categoryName = cat?.name ?? 'Bahan Utama';

    if (_isEdit) {
      widget.store.updateItem(widget.item!.copyWith(
        sku: sku,
        name: name,
        categoryId: _categoryId,
        categoryName: categoryName,
        unit: unit,
        stock: stock,
        minimum: minimum,
      ));
      Navigator.of(context).pop(('Perubahan disimpan', _categoryId));
    } else {
      widget.store.addItem(
        sku: sku,
        name: name,
        categoryId: _categoryId,
        unit: unit,
        stock: stock,
        minimum: minimum,
      );
      Navigator.of(context).pop(('Bahan baru ditambahkan', _categoryId));
    }
  }

  void _delete() {
    final item = widget.item!;
    widget.store.deleteItem(item.id);
    Navigator.of(context).pop(('"${item.name}" dihapus', item.categoryId));
  }

  @override
  Widget build(BuildContext context) {
    final decimalFormatter = FilteringTextInputFormatter.allow(
      RegExp(r'[0-9.,]'),
    );
    final categories = widget.store.categories;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: MochiTheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEdit ? 'Ubah Bahan Baku' : 'Tambah Bahan Baku',
                      style: const TextStyle(
                        color: MochiTheme.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const FieldLabel('Kategori Bahan'),
                  TextButton.icon(
                    onPressed: _dialogAddCategory,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('+ Kategori Baru', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: MochiTheme.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<int>(
                value: categories.any((c) => c.id == _categoryId) ? _categoryId : (categories.isNotEmpty ? categories.first.id : null),
                isExpanded: true,
                items: [
                  for (final cat in categories)
                    DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name, style: const TextStyle(fontSize: 13)),
                    ),
                ],
                onChanged: (id) {
                  if (id != null) setState(() => _categoryId = id);
                },
              ),
              const SizedBox(height: 12),
              const FieldLabel('Kode / SKU (Opsional)'),
              TextFormField(
                controller: _sku,
                decoration: const InputDecoration(hintText: 'Contoh: MCH-TPG-KETAN-500G'),
              ),
              const SizedBox(height: 12),
              const FieldLabel('Nama Bahan'),
              TextFormField(
                controller: _name,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama bahan wajib diisi.' : null,
                decoration: const InputDecoration(hintText: 'Contoh: Tepung Ketan'),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Stok Awal'),
                        TextFormField(
                          controller: _stock,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [decimalFormatter],
                          validator: (v) => _validateNumber(v, 'Stok awal'),
                          decoration: const InputDecoration(hintText: '0'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Batas Minimum'),
                        TextFormField(
                          controller: _minimum,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [decimalFormatter],
                          validator: (v) => _validateNumber(v, 'Batas minimum'),
                          decoration: const InputDecoration(hintText: '0'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Satuan'),
                        TextFormField(
                          controller: _unit,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Wajib diisi.' : null,
                          decoration: const InputDecoration(hintText: 'kg / pack'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _save,
                child: Text(_isEdit ? 'Simpan perubahan' : 'Tambah bahan'),
              ),
              if (_isEdit) ...[
                const SizedBox(height: 8),
                if (!_confirmDelete)
                  OutlinedButton(
                    onPressed: () => setState(() => _confirmDelete = true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: MochiTheme.primary,
                      side: const BorderSide(color: MochiTheme.primary),
                    ),
                    child: const Text('Hapus bahan ini'),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MochiTheme.softPink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Yakin ingin menghapus bahan ini?',
                          style: TextStyle(
                            color: MochiTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    setState(() => _confirmDelete = false),
                                child: const Text('Batal'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: _delete,
                                style: FilledButton.styleFrom(
                                  backgroundColor: MochiTheme.primary,
                                ),
                                child: const Text('Ya, hapus'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

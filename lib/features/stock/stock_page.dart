import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mochi_stok/core/format.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/data/inventory_store.dart';
import 'package:mochi_stok/models/item.dart';
import 'package:mochi_stok/models/stock_record.dart';
import 'package:mochi_stok/widgets/form_widgets.dart';
import 'package:mochi_stok/widgets/mochi_card.dart';
import 'package:mochi_stok/widgets/page_header.dart';
import 'package:mochi_stok/widgets/stock_widgets.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key, this.initialItemId, this.onSaved});

  // Item yang langsung terpilih (dipakai saat datang dari "Perlu diisi ulang").
  final int? initialItemId;
  // Dipanggil setelah stok berhasil dicatat (Shell kembali ke Beranda).
  final VoidCallback? onSaved;

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final _qty = TextEditingController();
  final _note = TextEditingController();
  int? _itemId;
  StockDirection _direction = StockDirection.masuk;
  String? _error;

  @override
  void initState() {
    super.initState();
    _itemId = widget.initialItemId;
  }

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit(InventoryStore store, Item item) {
    final quantity = parseNumber(_qty.text);
    if (quantity == null || quantity <= 0) {
      setState(() => _error = 'Isi jumlah dengan angka lebih dari 0.');
      return;
    }

    final error = store.recordStock(
      itemId: item.id,
      direction: _direction,
      quantity: quantity,
      note: _note.text,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    // Ambil status terbaru setelah stok berubah untuk pesan peringatan.
    final updated = store.findById(item.id);
    var message = '${_direction.label} ${formatQuantity(quantity, item.unit)} '
        '${item.name}';
    if (updated != null && updated.status != StockStatus.aman) {
      message += '. Stok ${updated.status.label.toLowerCase()}!';
    }

    setState(() {
      _error = null;
      _qty.clear();
      _note.clear();
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final store = InventoryScope.of(context);
    final items = store.items;
    final selected = store.findById(_itemId) ?? (items.isEmpty ? null : items.first);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const PageHeader(title: 'Catat stok', subtitle: 'Stok masuk atau keluar'),
          const SizedBox(height: 14),
          if (selected == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'Belum ada item. Tambah item dulu di tab Item.',
                  style: TextStyle(color: MochiTheme.muted, fontSize: 12),
                ),
              ),
            )
          else
            ..._buildForm(store, items, selected),
        ],
      ),
    );
  }

  List<Widget> _buildForm(InventoryStore store, List<Item> items, Item selected) {
    // Bahan baku ditampilkan dulu, lalu mochi jadi.
    final sorted = [
      ...items.where((i) => i.type == ItemType.bahan),
      ...items.where((i) => i.type == ItemType.produk),
    ];

    // Pratinjau stok setelah pencatatan.
    final qty = parseNumber(_qty.text);
    final after = qty == null
        ? selected.stock
        : (_direction == StockDirection.masuk
            ? selected.stock + qty
            : selected.stock - qty);
    final afterColor = after < 0
        ? MochiTheme.primary
        : (after < selected.minimum ? MochiTheme.primary : MochiTheme.ink);

    return [
      MochiSegmented<StockDirection>(
        options: {for (final d in StockDirection.values) d: 'Stok ${d.label.toLowerCase()}'},
        value: _direction,
        onChanged: (d) => setState(() {
          _direction = d;
          _error = null;
        }),
      ),
      const SizedBox(height: 14),
      const FieldLabel('Item'),
      DropdownButtonFormField<int>(
        initialValue: selected.id,
        isExpanded: true,
        decoration: const InputDecoration(),
        items: [
          for (final item in sorted)
            DropdownMenuItem(
              value: item.id,
              child: Text(
                '${item.name} (${item.type.label})',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
        ],
        onChanged: (id) {
          if (id == null) return;
          setState(() {
            _itemId = id;
            _error = null;
          });
        },
      ),
      const SizedBox(height: 12),
      MochiCard(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stok sekarang',
                    style: TextStyle(color: MochiTheme.muted, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatQuantity(selected.stock, selected.unit),
                    style: const TextStyle(
                      color: MochiTheme.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            StockStatusPill(selected.status),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldLabel('Jumlah (${selected.unit})'),
                TextField(
                  controller: _qty,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  onChanged: (_) => setState(() => _error = null),
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
                const FieldLabel('Stok setelah'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: MochiTheme.outline),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    formatNumber(after),
                    style: TextStyle(
                      color: afterColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      const FieldLabel('Catatan'),
      TextField(
        controller: _note,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: _direction == StockDirection.masuk
              ? 'Contoh: produksi pagi'
              : 'Contoh: pesanan pelanggan',
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: 10),
        Text(
          _error!,
          style: const TextStyle(
            color: MochiTheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
      const SizedBox(height: 18),
      FilledButton(
        onPressed: () => _submit(store, selected),
        child: Text(
          _direction == StockDirection.masuk
              ? 'Simpan stok masuk'
              : 'Simpan stok keluar',
        ),
      ),
    ];
  }
}

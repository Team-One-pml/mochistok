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
    final isLowOrCritical = updated != null && updated.status != StockStatus.aman;

    setState(() {
      _error = null;
      _qty.clear();
      _note.clear();
    });

    // Tampilkan SnackBar notifikasi dengan warna dinamis (merah jika menipis/habis)
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isLowOrCritical ? const Color(0xFFC53030) : const Color(0xFF2B8A3E),
      content: Row(
        children: [
          Icon(
            isLowOrCritical ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isLowOrCritical
                  ? 'Perhatian: Stok ${item.name} kini tersisa ${formatQuantity(updated.stock, updated.unit)} (${updated.status.label.toUpperCase()})!'
                  : '${_direction.label} ${formatQuantity(quantity, item.unit)} ${item.name} berhasil disimpan.',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
      duration: Duration(seconds: isLowOrCritical ? 4 : 2),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);

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
          const PageHeader(title: 'Catat stok', subtitle: 'Stok masuk atau keluar bahan baku'),
          const SizedBox(height: 14),
          if (selected == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'Belum ada bahan baku. Tambah bahan dulu di tab Bahan Baku.',
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

    // Deteksi apakah stok setelah transaksi ini akan menjadi habis / menipis / mendekati minimum
    final isDepleted = after <= 0;
    final isLow = after > 0 && after < selected.minimum;
    final isNearMinimum = after >= selected.minimum && after <= (selected.minimum * 1.25);

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
      const FieldLabel('Bahan Baku'),
      DropdownButtonFormField<int>(
        initialValue: selected.id,
        isExpanded: true,
        decoration: const InputDecoration(),
        items: [
          for (final item in items)
            DropdownMenuItem(
              value: item.id,
              child: Text(
                '${item.name} (${item.categoryName})',
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
                    border: Border.all(
                      color: (isDepleted || isLow)
                          ? MochiTheme.primary
                          : (isNearMinimum ? Colors.orange : MochiTheme.outline),
                      width: (isDepleted || isLow || isNearMinimum) ? 1.5 : 1,
                    ),
                    color: (isDepleted || isLow)
                        ? MochiTheme.softPink.withValues(alpha: 0.3)
                        : (isNearMinimum ? Colors.orange.withValues(alpha: 0.08) : Colors.white),
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
      // REAL-TIME WARNING BANNER JIKA STOK MENIPIS / MENDEKATI MINIMUM
      if (_direction == StockDirection.keluar && (isDepleted || isLow || isNearMinimum)) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: (isDepleted || isLow) ? const Color(0xFFFFECEF) : const Color(0xFFFFF4E6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (isDepleted || isLow) ? MochiTheme.primary.withValues(alpha: 0.5) : Colors.orange.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: (isDepleted || isLow) ? MochiTheme.primary : const Color(0xFFD97706),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isDepleted
                      ? 'Peringatan: Stok bahan akan HABIS (0 ${selected.unit}) setelah pengeluaran ini!'
                      : (isLow
                          ? 'Perhatian: Sisa stok (${formatNumber(after)} ${selected.unit}) berada di bawah batas minimum (${formatQuantity(selected.minimum, selected.unit)})!'
                          : 'Peringatan Dini: Sisa stok (${formatNumber(after)} ${selected.unit}) sudah mendekati batas minimum (${formatQuantity(selected.minimum, selected.unit)}). Segera jadwalkan pembelian ulang.'),
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: (isDepleted || isLow) ? MochiTheme.primary : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 12),
      const FieldLabel('Catatan'),
      TextField(
        controller: _note,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: _direction == StockDirection.masuk
              ? 'Contoh: pasokan supplier baru'
              : 'Contoh: dipakai untuk adonan kloter 1',
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

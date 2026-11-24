import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/data/inventory_store.dart';
import 'package:mochi_stok/models/stock_record.dart';
import 'package:mochi_stok/widgets/mochi_card.dart';
import 'package:mochi_stok/widgets/page_header.dart';
import 'package:mochi_stok/widgets/stock_widgets.dart';

enum ReportPeriod {
  today('Hari ini'),
  thisWeek('Minggu ini'),
  thisMonth('Bulan ini'),
  all('Semua');

  const ReportPeriod(this.label);
  final String label;
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  ReportPeriod _period = ReportPeriod.thisMonth;
  StockDirection? _directionFilter; // null = semua, masuk, atau keluar
  int? _categoryFilter; // null = semua kategori

  List<StockRecord> _filterHistory(List<StockRecord> raw, InventoryStore store) {
    final now = DateTime.now();

    return raw.where((r) {
      // 1. Filter Periode Waktu
      final date = r.time;
      var inPeriod = true;
      switch (_period) {
        case ReportPeriod.today:
          inPeriod = date.year == now.year && date.month == now.month && date.day == now.day;
        case ReportPeriod.thisWeek:
          final diffDays = now.difference(date).inDays;
          inPeriod = diffDays <= 7 && date.isBefore(now.add(const Duration(days: 1)));
        case ReportPeriod.thisMonth:
          inPeriod = date.year == now.year && date.month == now.month;
        case ReportPeriod.all:
          inPeriod = true;
      }
      if (!inPeriod) return false;

      // 2. Filter Arah Mutasi (Masuk / Keluar)
      if (_directionFilter != null && r.direction != _directionFilter) {
        return false;
      }

      // 3. Filter Kategori Bahan
      if (_categoryFilter != null) {
        final item = store.findById(r.itemId);
        if (item == null || item.categoryId != _categoryFilter) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _exportCsv(List<StockRecord> data) {
    // Simulasi ekspor laporan ke CSV / Spreadsheet
    final buffer = StringBuffer();
    buffer.writeln('ID,Waktu,Nama Bahan,Arah,Kuantitas,Satuan,Sisa Stok,Catatan');
    for (final r in data) {
      buffer.writeln(
        '${r.id},"${r.time}",${r.itemName},${r.direction.name},${r.quantity},${r.unit},${r.stockAfter},"${r.note}"',
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Laporan ${data.length} transaksi siap diekspor! (Format CSV)'),
        backgroundColor: MochiTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = InventoryScope.of(context);
    final filtered = _filterHistory(store.history, store);

    // Hitung ringkasan statistik
    final totalMasuk = filtered.where((r) => r.direction == StockDirection.masuk).length;
    final totalKeluar = filtered.where((r) => r.direction == StockDirection.keluar).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: PageHeader(
                  title: 'Laporan Stok',
                  subtitle: 'Rekapitulasi mutasi dan analisis pemakaian bahan',
                ),
              ),
              IconButton.filledTonal(
                onPressed: filtered.isEmpty ? null : () => _exportCsv(filtered),
                icon: const Icon(Icons.download_rounded, size: 20),
                tooltip: 'Ekspor Data CSV',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Selector Periode Waktu
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final p in ReportPeriod.values) ...[
                  ChoiceChip(
                    label: Text(p.label),
                    selected: _period == p,
                    onSelected: (val) {
                      if (val) setState(() => _period = p);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Kartu Ringkasan Mutasi (KPI Stat Cards)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MochiTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_downward, size: 14, color: MochiTheme.success),
                          const SizedBox(width: 4),
                          const Text('Stok Masuk', style: TextStyle(color: MochiTheme.muted, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$totalMasuk transaksi',
                        style: const TextStyle(
                          color: MochiTheme.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MochiTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_upward, size: 14, color: MochiTheme.primary),
                          const SizedBox(width: 4),
                          const Text('Stok Keluar', style: TextStyle(color: MochiTheme.muted, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$totalKeluar transaksi',
                        style: const TextStyle(
                          color: MochiTheme.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Filter Mutasi & Kategori
          Row(
            children: [
              // Filter Direction
              Expanded(
                child: DropdownButtonFormField<StockDirection?>(
                  initialValue: _directionFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    labelText: 'Arah Transaksi',
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Semua Arah', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: StockDirection.masuk, child: Text('Hanya Masuk', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: StockDirection.keluar, child: Text('Hanya Keluar', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) => setState(() => _directionFilter = val),
                ),
              ),
              const SizedBox(width: 10),
              // Filter Category
              Expanded(
                child: DropdownButtonFormField<int?>(
                  initialValue: _categoryFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    labelText: 'Kategori Bahan',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Semua Kategori', style: TextStyle(fontSize: 12))),
                    for (final cat in store.categories)
                      DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name, style: const TextStyle(fontSize: 12)),
                      ),
                  ],
                  onChanged: (val) => setState(() => _categoryFilter = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4. Tabel Daftar Riwayat Terfilter
          MochiCard(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
            child: filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        'Tidak ada data mutasi pada periode dan filter ini.',
                        style: TextStyle(color: MochiTheme.muted, fontSize: 12),
                      ),
                    ),
                  )
                : Column(
                    children: withDividers([
                      for (final record in filtered) HistoryTile(record: record),
                    ]),
                  ),
          ),
        ],
      ),
    );
  }
}

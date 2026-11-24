import 'package:flutter/material.dart';
import 'package:mochi_stok/core/report_export.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/data/inventory_store.dart';
import 'package:mochi_stok/models/stock_record.dart';
import 'package:mochi_stok/widgets/mochi_card.dart';
import 'package:mochi_stok/widgets/page_header.dart';
import 'package:mochi_stok/widgets/stock_widgets.dart';

enum ReportPeriod {
  today('Hari ini'),
  thisWeek('7 hari terakhir'),
  thisMonth('Bulan ini'),
  all('Semua');

  const ReportPeriod(this.label);
  final String label;
}

enum _ExportFormat { pdf, csv }

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const _defaultPeriod = ReportPeriod.thisMonth;

  final _search = TextEditingController();
  String _query = '';
  ReportPeriod _period = _defaultPeriod;
  StockDirection? _direction; // null = semua arah
  int? _categoryId; // null = semua kategori

  bool get _hasFilter =>
      _period != _defaultPeriod ||
      _direction != null ||
      _categoryId != null ||
      _query.isNotEmpty;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _search.clear();
    setState(() {
      _query = '';
      _period = _defaultPeriod;
      _direction = null;
      _categoryId = null;
    });
  }

  bool _inPeriod(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (_period) {
      ReportPeriod.today =>
        t.year == now.year && t.month == now.month && t.day == now.day,
      // 7 hari terakhir, termasuk hari ini.
      ReportPeriod.thisWeek => !t.isBefore(
        today.subtract(const Duration(days: 6)),
      ),
      ReportPeriod.thisMonth => t.year == now.year && t.month == now.month,
      ReportPeriod.all => true,
    };
  }

  List<StockRecord> _filter(InventoryStore store) {
    return store.history.where((r) {
      if (!_inPeriod(r.time)) return false;
      if (_direction != null && r.direction != _direction) return false;
      if (_categoryId != null) {
        final item = store.findById(r.itemId);
        if (item == null || item.categoryId != _categoryId) return false;
      }
      if (_query.isNotEmpty &&
          !r.itemName.toLowerCase().contains(_query) &&
          !r.note.toLowerCase().contains(_query)) {
        return false;
      }
      return true;
    }).toList();
  }

  String _categoryNameById(InventoryStore store, int? id) {
    for (final c in store.categories) {
      if (c.id == id) return c.name;
    }
    return '-';
  }

  String _filterLabel(InventoryStore store) {
    final parts = <String>['Periode ${_period.label}'];
    if (_direction != null) {
      parts.add(
        'Arah ${_direction == StockDirection.masuk ? 'Masuk' : 'Keluar'}',
      );
    }
    if (_categoryId != null) {
      parts.add('Kategori ${_categoryNameById(store, _categoryId)}');
    }
    if (_query.isNotEmpty) parts.add('Pencarian "$_query"');
    return parts.join(', ');
  }

  String _stamp() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${two(n.month)}${two(n.day)}';
  }

  void _snack(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(text),
        backgroundColor: error ? Colors.red : MochiTheme.success,
      ),
    );
  }

  Future<void> _export(_ExportFormat format, InventoryStore store) async {
    final rows = [
      for (final r in _filter(store))
        ReportRow(
          r,
          _categoryNameById(store, store.findById(r.itemId)?.categoryId),
        ),
    ];
    final fileName = 'laporan-mochi-stock-${_stamp()}';

    try {
      if (format == _ExportFormat.pdf) {
        await exportReportPdf(
          rows: rows,
          filterLabel: _filterLabel(store),
          fileName: fileName,
        );
      } else {
        await exportReportCsv(rows: rows, fileName: fileName);
      }
      if (!mounted) return;
      _snack(
        'Laporan ${format == _ExportFormat.pdf ? 'PDF' : 'CSV'} berhasil diekspor.',
      );
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal mengekspor laporan: $e', error: true);
    }
  }

  void _openExportSheet(InventoryStore store, int count) {
    if (count == 0) {
      _snack('Tidak ada data untuk diekspor pada filter ini.', error: true);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ekspor laporan',
                style: TextStyle(
                  color: MochiTheme.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count pencatatan sesuai filter yang aktif',
                style: const TextStyle(color: MochiTheme.muted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('PDF'),
                subtitle: const Text('Untuk dicetak atau dibagikan'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _export(_ExportFormat.pdf, store);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.table_chart_outlined),
                title: const Text('CSV'),
                subtitle: const Text(
                  'Untuk dibuka di Excel atau Google Sheets',
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _export(_ExportFormat.csv, store);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = InventoryScope.of(context);
    final filtered = _filter(store);

    final totalMasuk = filtered
        .where((r) => r.direction == StockDirection.masuk)
        .length;
    final totalKeluar = filtered
        .where((r) => r.direction == StockDirection.keluar)
        .length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          // Judul + tombol ekspor
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: PageHeader(
                  title: 'Laporan',
                  subtitle: 'Rekap pencatatan stok masuk dan keluar',
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: () => _openExportSheet(store, filtered.length),
                icon: const Icon(Icons.file_download_outlined, size: 18),
                label: const Text('Ekspor laporan'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Pencarian
          TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Cari nama bahan atau catatan',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus pencarian',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 10),

          // Periode
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final p in ReportPeriod.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p.label),
                      selected: _period == p,
                      onSelected: (_) => setState(() => _period = p),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Arah dan kategori
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<StockDirection?>(
                  key: ValueKey('arah-${_direction?.name}'),
                  initialValue: _direction,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    labelText: 'Arah',
                  ),
                  items: const [
                    DropdownMenuItem<StockDirection?>(
                      value: null,
                      child: Text('Semua', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem<StockDirection?>(
                      value: StockDirection.masuk,
                      child: Text('Masuk', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem<StockDirection?>(
                      value: StockDirection.keluar,
                      child: Text('Keluar', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  onChanged: (val) => setState(() => _direction = val),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  key: ValueKey('kategori-$_categoryId'),
                  initialValue: _categoryId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    labelText: 'Kategori',
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Semua', style: TextStyle(fontSize: 12)),
                    ),
                    for (final cat in store.categories)
                      DropdownMenuItem<int?>(
                        value: cat.id,
                        child: Text(
                          cat.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                  onChanged: (val) => setState(() => _categoryId = val),
                ),
              ),
            ],
          ),
          if (_hasFilter)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.restart_alt, size: 16),
                label: const Text('Reset filter'),
                style: TextButton.styleFrom(
                  foregroundColor: MochiTheme.primary,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Ringkasan
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.arrow_downward,
                  color: MochiTheme.success,
                  label: 'Stok masuk',
                  value: totalMasuk,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.arrow_upward,
                  color: MochiTheme.primary,
                  label: 'Stok keluar',
                  value: totalKeluar,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Riwayat
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Row(
              children: [
                const Text(
                  'Riwayat',
                  style: TextStyle(
                    color: MochiTheme.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${filtered.length} pencatatan',
                  style: const TextStyle(color: MochiTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          MochiCard(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        store.history.isEmpty
                            ? 'Belum ada pencatatan stok.'
                            : 'Tidak ada pencatatan pada filter ini.',
                        style: const TextStyle(
                          color: MochiTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: withDividers([
                      for (final record in filtered)
                        HistoryTile(record: record),
                    ]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: MochiTheme.muted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$value',
                  style: const TextStyle(
                    color: MochiTheme.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const TextSpan(
                  text: ' transaksi',
                  style: TextStyle(color: MochiTheme.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:mochi_stok/models/stock_record.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Satu baris laporan yang siap diekspor (pencatatan + nama kategorinya).
class ReportRow {
  const ReportRow(this.record, this.category);

  final StockRecord record;
  final String category;
}

String _two(int n) => n.toString().padLeft(2, '0');

String _waktu(DateTime t) =>
    '${t.year}-${_two(t.month)}-${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}';

String _arah(StockDirection d) =>
    d == StockDirection.masuk ? 'Masuk' : 'Keluar';

// 12.0 -> "12", 0.8 -> "0,8"
String _angka(double v) {
  final rounded = (v * 100).round() / 100;
  if (rounded == rounded.roundToDouble()) return rounded.toInt().toString();
  return rounded.toString().replaceAll('.', ',');
}

String _csvCell(String v) => '"${v.replaceAll('"', '""')}"';

/// Ekspor ke CSV. Pemisah titik koma (;) dan BOM UTF-8 supaya langsung
/// terbaca rapi di Excel berbahasa Indonesia.
Future<void> exportReportCsv({
  required List<ReportRow> rows,
  required String fileName,
}) async {
  final buffer = StringBuffer()
    ..writeln('Waktu;Item;Kategori;Arah;Jumlah;Satuan;Sisa stok;Catatan');
  for (final row in rows) {
    final r = row.record;
    buffer.writeln(
      [
        _csvCell(_waktu(r.time)),
        _csvCell(r.itemName),
        _csvCell(row.category),
        _csvCell(_arah(r.direction)),
        _angka(r.quantity),
        _csvCell(r.unit),
        _angka(r.stockAfter),
        _csvCell(r.note),
      ].join(';'),
    );
  }

  final bytes = Uint8List.fromList(utf8.encode('\uFEFF$buffer'));
  await FileSaver.instance.saveFile(
    name: fileName,
    bytes: bytes,
    fileExtension: 'csv',
    mimeType: MimeType.csv,
  );
}

/// Ekspor ke PDF: ringkasan + tabel pencatatan sesuai filter yang aktif.
Future<void> exportReportPdf({
  required List<ReportRow> rows,
  required String filterLabel,
  required String fileName,
}) async {
  final masuk = rows
      .where((r) => r.record.direction == StockDirection.masuk)
      .length;
  final keluar = rows
      .where((r) => r.record.direction == StockDirection.keluar)
      .length;

  final judul = pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold);
  final kepala = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
  const isi = pw.TextStyle(fontSize: 10);

  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Text(
          'Laporan Mochi Stock',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text('Dicetak ${_waktu(DateTime.now())}', style: isi),
        pw.Text('Filter: $filterLabel', style: isi),
        pw.SizedBox(height: 16),
        pw.Text('Ringkasan', style: judul),
        pw.SizedBox(height: 6),
        pw.Text('Stok masuk: $masuk transaksi', style: isi),
        pw.Text('Stok keluar: $keluar transaksi', style: isi),
        pw.SizedBox(height: 16),
        pw.Text('Riwayat', style: judul),
        pw.SizedBox(height: 6),
        if (rows.isEmpty)
          pw.Text('Tidak ada pencatatan pada filter ini.', style: isi)
        else
          pw.TableHelper.fromTextArray(
            headers: ['Waktu', 'Item', 'Kategori', 'Arah', 'Jumlah', 'Catatan'],
            data: [
              for (final row in rows)
                [
                  _waktu(row.record.time),
                  row.record.itemName,
                  row.category,
                  _arah(row.record.direction),
                  '${_angka(row.record.quantity)} ${row.record.unit}',
                  row.record.note.isEmpty ? '-' : row.record.note,
                ],
            ],
            headerStyle: kepala,
            cellStyle: isi,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellPadding: const pw.EdgeInsets.all(4),
            cellAlignment: pw.Alignment.centerLeft,
          ),
      ],
    ),
  );

  final bytes = await doc.save();
  await FileSaver.instance.saveFile(
    name: fileName,
    bytes: bytes,
    fileExtension: 'pdf',
    mimeType: MimeType.pdf,
  );
}

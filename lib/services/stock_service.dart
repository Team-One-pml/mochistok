import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mochi_stok/models/item.dart';
import 'package:mochi_stok/models/stock_transaction.dart';
import 'package:mochi_stok/models/stock_record.dart';

/// Service untuk menangani transaksi pergerakan stok (`stock_movements`)
/// dan persistensi data item & riwayat secara asynchronous.
///
/// Dirancang dengan pola API Service:
/// - Saat ini menggunakan Local Storage (SharedPreferences) sehingga data aman saat refresh.
/// - Siap dihubungkan ke REST API MySQL kapan saja (cukup aktifkan pemanggilan HTTP).
class StockService {
  StockService({this.baseUrl = 'http://localhost/api'});

  final String baseUrl;

  static const String _keyItems = 'mochi_stok_items';
  static const String _keyHistory = 'mochi_stok_history';

  /// Memuat daftar item tersimpan dari penyimpanan lokal (Local Database/Storage)
  Future<List<Item>?> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyItems);
    if (raw == null) return null; // Belum pernah disimpan, gunakan data awal (seed)

    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Menyimpan seluruh item ke penyimpanan lokal
  Future<void> saveItems(List<Item> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((i) => i.toJson()).toList());
    await prefs.setString(_keyItems, raw);
  }

  /// Memuat riwayat mutasi stok dari penyimpanan lokal
  Future<List<StockRecord>?> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyHistory);
    if (raw == null) return null;

    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => StockRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Menyimpan riwayat mutasi stok
  Future<void> saveHistory(List<StockRecord> history) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(history.map((h) => h.toJson()).toList());
    await prefs.setString(_keyHistory, raw);
  }

  /// Mencatat pergerakan stok masuk atau keluar ke tabel `stock_movements`.
  /// Memvalidasi integritas bisnis seperti stok mencukupi untuk transaksi keluar.
  Future<StockTransaction> recordMovement({
    required int itemId,
    required String itemName,
    required String unit,
    required StockDirection direction,
    required double quantity,
    required double currentStock,
    String note = '',
    String? pathBuktiNota,
  }) async {
    // Validasi kuantitas
    if (quantity <= 0) {
      throw ArgumentError('Kuantitas stok harus lebih dari 0.');
    }

    // Validasi integritas bisnis: Stok keluar tidak boleh melebihi sisa stok
    if (direction == StockDirection.keluar && quantity > currentStock) {
      throw StateError(
        'Stok tidak mencukupi! Stok saat ini: $currentStock $unit, diminta keluar: $quantity $unit.',
      );
    }

    final stockBefore = currentStock;
    final stockAfter = direction == StockDirection.masuk
        ? (currentStock + quantity)
        : (currentStock - quantity);

    // Pembulatan 2 desimal sesuai tipe DECIMAL(12,2) di database
    final roundedStockAfter = (stockAfter * 100).round() / 100;

    final transaction = StockTransaction(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      itemId: itemId,
      itemName: itemName,
      unit: unit,
      direction: direction,
      quantity: quantity,
      stockBefore: stockBefore,
      stockAfter: roundedStockAfter,
      note: note.trim(),
      pathBuktiNota: pathBuktiNota,
      createdAt: DateTime.now(),
    );

    // Di Skenario A, pemanggilan REST API ke MySQL:
    // await http.post(
    //   Uri.parse('$baseUrl/stock_movements'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(transaction.toJson()),
    // );

    return transaction;
  }
}

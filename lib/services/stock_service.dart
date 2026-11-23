import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mochi_stok/models/category.dart';
import 'package:mochi_stok/models/item.dart';
import 'package:mochi_stok/models/stock_transaction.dart';
import 'package:mochi_stok/models/stock_record.dart';

/// Service untuk menangani transaksi pergerakan stok (`stock_movements`)
/// dan persistensi data item, kategori & riwayat secara asynchronous.
class StockService {
  StockService({this.baseUrl = 'http://localhost/api'});

  final String baseUrl;

  static const String _keyCategories = 'mochi_stok_categories';
  static const String _keyItems = 'mochi_stok_items_v2';
  static const String _keyHistory = 'mochi_stok_history_v2';

  /// Memuat daftar kategori dari penyimpanan
  Future<List<Category>?> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCategories);
    if (raw == null) return null;

    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Menyimpan daftar kategori ke penyimpanan
  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_keyCategories, raw);
  }

  /// Memuat daftar item bahan baku tersimpan
  Future<List<Item>?> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyItems);
    if (raw == null) return null;

    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Menyimpan seluruh item ke penyimpanan
  Future<void> saveItems(List<Item> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((i) => i.toJson()).toList());
    await prefs.setString(_keyItems, raw);
  }

  /// Memuat riwayat mutasi stok
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
    if (quantity <= 0) {
      throw ArgumentError('Kuantitas stok harus lebih dari 0.');
    }

    if (direction == StockDirection.keluar && quantity > currentStock) {
      throw StateError(
        'Stok tidak mencukupi! Stok saat ini: $currentStock $unit, diminta keluar: $quantity $unit.',
      );
    }

    final stockBefore = currentStock;
    final stockAfter = direction == StockDirection.masuk
        ? (currentStock + quantity)
        : (currentStock - quantity);

    final roundedStockAfter = (stockAfter * 100).round() / 100;

    return StockTransaction(
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
  }
}

import 'package:flutter/widgets.dart';
import 'package:mochi_stok/core/format.dart';
import 'package:mochi_stok/models/item.dart';
import 'package:mochi_stok/models/stock_record.dart';

/// Sumber data tunggal untuk seluruh aplikasi (sementara masih di memori).
/// Semua halaman membaca dan mengubah data lewat kelas ini, jadi Beranda,
/// Item, Stok, dan Riwayat selalu sinkron.
///
/// Nanti kalau mau pakai SQLite/Firebase, cukup ubah isi kelas ini; halaman
/// lain tidak perlu diubah.
class InventoryStore extends ChangeNotifier {
  InventoryStore() {
    _loadSeed();
  }

  final List<Item> _items = [];
  final List<StockRecord> _history = []; // terbaru di indeks 0
  int _nextId = 100;

  List<Item> get items => List.unmodifiable(_items);
  List<StockRecord> get history => List.unmodifiable(_history);

  /// Item berstatus menipis/habis, yang paling kritis di atas.
  List<Item> get lowStockItems {
    final low = _items.where((i) => i.status != StockStatus.aman).toList();
    low.sort((a, b) => _ratio(a).compareTo(_ratio(b)));
    return low;
  }

  double _ratio(Item item) => item.minimum <= 0 ? 1 : item.stock / item.minimum;

  Item? findById(int? id) {
    if (id == null) return null;
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  void addItem({
    required String name,
    required ItemType type,
    required String unit,
    required double stock,
    required double minimum,
  }) {
    _items.add(Item(
      id: _nextId++,
      name: name,
      type: type,
      unit: unit,
      stock: stock,
      minimum: minimum,
    ));
    notifyListeners();
  }

  void updateItem(Item updated) {
    final index = _items.indexWhere((i) => i.id == updated.id);
    if (index < 0) return;
    _items[index] = updated;
    notifyListeners();
  }

  void deleteItem(int id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  /// Mencatat stok masuk/keluar. Mengembalikan pesan error bila gagal,
  /// atau null bila berhasil.
  String? recordStock({
    required int itemId,
    required StockDirection direction,
    required double quantity,
    String note = '',
  }) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index < 0) return 'Item tidak ditemukan.';
    final item = _items[index];

    if (quantity <= 0) return 'Isi jumlah dengan angka lebih dari 0.';
    if (direction == StockDirection.keluar && quantity > item.stock) {
      return 'Stok ${item.name} hanya tersisa '
          '${formatQuantity(item.stock, item.unit)}. Kurangi jumlah keluar.';
    }

    final raw = direction == StockDirection.masuk
        ? item.stock + quantity
        : item.stock - quantity;
    final newStock = (raw * 100).round() / 100; // hindari 0.30000000000000004

    _items[index] = item.copyWith(stock: newStock);
    _history.insert(
      0,
      StockRecord(
        id: _nextId++,
        time: DateTime.now(),
        itemId: item.id,
        itemName: item.name,
        direction: direction,
        quantity: quantity,
        unit: item.unit,
        note: note.trim(),
        stockAfter: newStock,
      ),
    );
    notifyListeners();
    return null;
  }

  void reset() {
    _items.clear();
    _history.clear();
    _loadSeed();
    notifyListeners();
  }

  void _loadSeed() {
    _items.addAll(const [
      Item(id: 1, name: 'Tepung ketan', type: ItemType.bahan, unit: 'kg', stock: 12, minimum: 10),
      Item(id: 2, name: 'Gula pasir', type: ItemType.bahan, unit: 'kg', stock: 4, minimum: 5),
      Item(id: 3, name: 'Kacang tanah sangrai', type: ItemType.bahan, unit: 'kg', stock: 6.5, minimum: 3),
      Item(id: 4, name: 'Bubuk matcha', type: ItemType.bahan, unit: 'kg', stock: 0.8, minimum: 1),
      Item(id: 5, name: 'Mochi kacang', type: ItemType.produk, unit: 'pcs', stock: 48, minimum: 30),
      Item(id: 6, name: 'Mochi matcha', type: ItemType.produk, unit: 'pcs', stock: 22, minimum: 30),
      Item(id: 7, name: 'Mochi cokelat', type: ItemType.produk, unit: 'pcs', stock: 35, minimum: 30),
      Item(id: 8, name: 'Mochi stroberi', type: ItemType.produk, unit: 'pcs', stock: 60, minimum: 30),
    ]);

    DateTime ago(int hours, [int minutes = 0]) =>
        DateTime.now().subtract(Duration(hours: hours, minutes: minutes));

    _history.addAll([
      StockRecord(id: 1, time: ago(1, 10), itemId: 6, itemName: 'Mochi matcha', direction: StockDirection.keluar, quantity: 18, unit: 'pcs', note: 'Pesanan kantor', stockAfter: 22),
      StockRecord(id: 2, time: ago(3), itemId: 5, itemName: 'Mochi kacang', direction: StockDirection.masuk, quantity: 40, unit: 'pcs', note: 'Produksi pagi', stockAfter: 48),
      StockRecord(id: 3, time: ago(4, 20), itemId: 2, itemName: 'Gula pasir', direction: StockDirection.keluar, quantity: 3, unit: 'kg', note: 'Dipakai produksi', stockAfter: 4),
      StockRecord(id: 4, time: ago(26), itemId: 1, itemName: 'Tepung ketan', direction: StockDirection.masuk, quantity: 10, unit: 'kg', note: 'Belanja pasar', stockAfter: 12),
    ]);
  }
}

/// Membuat store bisa diakses dari halaman mana pun:
///   final store = InventoryScope.of(context);
/// Halaman otomatis dibangun ulang saat data berubah.
class InventoryScope extends InheritedNotifier<InventoryStore> {
  const InventoryScope({
    super.key,
    required InventoryStore store,
    required super.child,
  }) : super(notifier: store);

  static InventoryStore of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<InventoryScope>();
    assert(scope != null, 'InventoryScope tidak ditemukan di atas widget ini.');
    return scope!.notifier!;
  }
}

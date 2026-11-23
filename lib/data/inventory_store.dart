import 'package:flutter/widgets.dart';
import 'package:mochi_stok/core/format.dart';
import 'package:mochi_stok/models/category.dart';
import 'package:mochi_stok/models/item.dart';
import 'package:mochi_stok/models/stock_record.dart';
import 'package:mochi_stok/services/stock_service.dart';

/// Sumber data tunggal untuk seluruh aplikasi.
/// Fokus 100% pada Inventaris Bahan Baku Mochi dengan dukungan Multi-Kategori Dinamis.
class InventoryStore extends ChangeNotifier {
  InventoryStore({StockService? service}) : _service = service ?? StockService() {
    _initialize();
  }

  final StockService _service;
  final List<Category> _categories = [];
  final List<Item> _items = [];
  final List<StockRecord> _history = [];
  int _nextId = 100;
  int _nextCategoryId = 10;

  List<Category> get categories => List.unmodifiable(_categories);
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

  Category? findCategoryById(int id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> _initialize() async {
    final savedCategories = await _service.loadCategories();
    final savedItems = await _service.loadItems();
    final savedHistory = await _service.loadHistory();

    // 1. Kategori
    if (savedCategories != null && savedCategories.isNotEmpty) {
      _categories.clear();
      _categories.addAll(savedCategories);
      _nextCategoryId = _categories.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
    } else {
      _loadDefaultCategories();
      await _service.saveCategories(_categories);
    }

    // 2. Items
    if (savedItems != null) {
      _items.clear();
      _items.addAll(savedItems);
      if (_items.isNotEmpty) {
        _nextId = _items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
      }
    } else {
      _loadSeedItems();
      await _service.saveItems(_items);
    }

    // 3. Riwayat
    if (savedHistory != null) {
      _history.clear();
      _history.addAll(savedHistory);
    } else {
      _loadSeedHistory();
      await _service.saveHistory(_history);
    }

    notifyListeners();
  }

  /// Menambah kategori bahan baru (misal: "Bahan Tambahan", "Packaging Khusus")
  Category addCategory(String name, {String description = ''}) {
    final newCategory = Category(
      id: _nextCategoryId++,
      name: name.trim(),
      description: description.trim(),
    );
    _categories.add(newCategory);
    _service.saveCategories(_categories);
    notifyListeners();
    return newCategory;
  }

  void addItem({
    String sku = '',
    required String name,
    required int categoryId,
    required String unit,
    required double stock,
    required double minimum,
  }) {
    final cat = findCategoryById(categoryId);
    _items.add(Item(
      id: _nextId++,
      sku: sku,
      name: name,
      categoryId: categoryId,
      categoryName: cat?.name ?? 'Bahan Utama',
      unit: unit,
      stock: stock,
      minimum: minimum,
    ));
    _service.saveItems(_items);
    notifyListeners();
  }

  void updateItem(Item updated) {
    final index = _items.indexWhere((i) => i.id == updated.id);
    if (index < 0) return;
    _items[index] = updated;
    _service.saveItems(_items);
    notifyListeners();
  }

  void deleteItem(int id) {
    _items.removeWhere((i) => i.id == id);
    _service.saveItems(_items);
    notifyListeners();
  }

  /// Mencatat stok masuk/keluar (sinkron dengan tabel `stock_movements`).
  String? recordStock({
    required int itemId,
    required StockDirection direction,
    required double quantity,
    String note = '',
    String? pathBuktiNota,
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
    final newStock = (raw * 100).round() / 100;

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

    _service.saveItems(_items);
    _service.saveHistory(_history);

    notifyListeners();
    return null;
  }

  void reset() {
    _categories.clear();
    _items.clear();
    _history.clear();
    _loadDefaultCategories();
    _loadSeedItems();
    _loadSeedHistory();
    _service.saveCategories(_categories);
    _service.saveItems(_items);
    _service.saveHistory(_history);
    notifyListeners();
  }

  void _loadDefaultCategories() {
    _categories.addAll(const [
      Category(id: 1, name: 'Bahan Utama', description: 'Tepung, gula, dan bahan adonan inti'),
      Category(id: 2, name: 'Topping & Isian', description: 'Selai, cokelat, kacang, dan filling'),
      Category(id: 3, name: 'Packaging', description: 'Mika, cup, kotak kemasan'),
    ]);
  }

  void _loadSeedItems() {
    _items.addAll(const [
      Item(id: 1, sku: 'MCH-TPG-KETAN-500G', name: 'Tepung Ketan Bola', categoryId: 1, categoryName: 'Bahan Utama', unit: 'kg', stock: 12, minimum: 10),
      Item(id: 2, sku: 'MCH-GLA-PASIR-1KG', name: 'Gula Pasir', categoryId: 1, categoryName: 'Bahan Utama', unit: 'kg', stock: 4, minimum: 5),
      Item(id: 3, sku: 'MCH-TPG-MZNA-1KG', name: 'Tepung Maizena', categoryId: 1, categoryName: 'Bahan Utama', unit: 'kg', stock: 5, minimum: 3),
      Item(id: 4, sku: 'TOP-CKL-FILL-5KG', name: 'Coklat Filling', categoryId: 2, categoryName: 'Topping & Isian', unit: 'kg', stock: 6.5, minimum: 4),
      Item(id: 5, sku: 'TOP-SEL-STRWB-1KG', name: 'Selai Strawberry', categoryId: 2, categoryName: 'Topping & Isian', unit: 'kg', stock: 2, minimum: 3),
      Item(id: 6, sku: 'TOP-NUT-JAR-350G', name: 'Nutella Jar 350g', categoryId: 2, categoryName: 'Topping & Isian', unit: 'gram', stock: 700, minimum: 1000),
      Item(id: 7, sku: 'PCK-MKA-6A-PCK', name: 'Mika 6A', categoryId: 3, categoryName: 'Packaging', unit: 'pack', stock: 25, minimum: 20),
      Item(id: 8, sku: 'PCK-CUP-25ML-PCK', name: 'Cup Mika 25ml', categoryId: 3, categoryName: 'Packaging', unit: 'pack', stock: 8, minimum: 15),
    ]);
  }

  void _loadSeedHistory() {
    DateTime ago(int hours, [int minutes = 0]) =>
        DateTime.now().subtract(Duration(hours: hours, minutes: minutes));

    _history.addAll([
      StockRecord(id: 1, time: ago(1, 10), itemId: 7, itemName: 'Mika 6A', direction: StockDirection.keluar, quantity: 5, unit: 'pack', note: 'Packing pesanan', stockAfter: 25),
      StockRecord(id: 2, time: ago(3), itemId: 4, itemName: 'Coklat Filling', direction: StockDirection.masuk, quantity: 5, unit: 'kg', note: 'Restock supplier', stockAfter: 6.5),
      StockRecord(id: 3, time: ago(4, 20), itemId: 2, itemName: 'Gula Pasir', direction: StockDirection.keluar, quantity: 3, unit: 'kg', note: 'Produksi adonan', stockAfter: 4),
      StockRecord(id: 4, time: ago(26), itemId: 1, itemName: 'Tepung Ketan Bola', direction: StockDirection.masuk, quantity: 10, unit: 'kg', note: 'Belanja grosir', stockAfter: 12),
    ]);
  }
}

/// Membuat store bisa diakses dari halaman mana pun:
///   final store = InventoryScope.of(context);
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

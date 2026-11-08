// Jenis item: bahan baku atau mochi jadi.
enum ItemType {
  bahan('Bahan baku'),
  produk('Mochi jadi');

  const ItemType(this.label);
  final String label;
}

// Status stok dihitung otomatis dari jumlah stok dan batas minimum.
enum StockStatus {
  aman('Aman'),
  menipis('Menipis'),
  habis('Habis');

  const StockStatus(this.label);
  final String label;
}

class Item {
  const Item({
    required this.id,
    required this.name,
    required this.type,
    required this.unit,
    required this.stock,
    required this.minimum,
  });

  final int id;
  final String name;
  final ItemType type;
  final String unit;
  final double stock;
  final double minimum;

  StockStatus get status {
    if (stock <= 0) return StockStatus.habis;
    if (stock < minimum) return StockStatus.menipis;
    return StockStatus.aman;
  }

  // Panjang bar: penuh bila stok sudah 2x batas minimum.
  double get progress {
    if (minimum <= 0) return 1;
    return (stock / (minimum * 2)).clamp(0.0, 1.0);
  }

  Item copyWith({
    String? name,
    ItemType? type,
    String? unit,
    double? stock,
    double? minimum,
  }) {
    return Item(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      minimum: minimum ?? this.minimum,
    );
  }
}

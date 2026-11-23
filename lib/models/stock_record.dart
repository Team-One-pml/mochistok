enum StockDirection {
  masuk('Masuk'),
  keluar('Keluar');

  const StockDirection(this.label);
  final String label;
}

// Satu baris riwayat pencatatan stok masuk/keluar.
class StockRecord {
  const StockRecord({
    required this.id,
    required this.time,
    required this.itemId,
    required this.itemName,
    required this.direction,
    required this.quantity,
    required this.unit,
    required this.note,
    required this.stockAfter,
  });

  final int id;
  final DateTime time;
  final int itemId;
  final String itemName;
  final StockDirection direction;
  final double quantity;
  final String unit;
  final String note;
  final double stockAfter;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'item_id': itemId,
      'item_name': itemName,
      'direction': direction.name,
      'quantity': quantity,
      'unit': unit,
      'note': note,
      'stock_after': stockAfter,
    };
  }

  factory StockRecord.fromJson(Map<String, dynamic> json) {
    return StockRecord(
      id: int.parse(json['id'].toString()),
      time: json['time'] != null
          ? DateTime.tryParse(json['time'].toString()) ?? DateTime.now()
          : DateTime.now(),
      itemId: int.parse(json['item_id'].toString()),
      itemName: json['item_name'] as String? ?? '',
      direction: json['direction'] == 'keluar'
          ? StockDirection.keluar
          : StockDirection.masuk,
      quantity: double.tryParse(json['quantity'].toString()) ?? 0.0,
      unit: json['unit'] as String? ?? '',
      note: json['note'] as String? ?? '',
      stockAfter: double.tryParse(json['stock_after'].toString()) ?? 0.0,
    );
  }
}

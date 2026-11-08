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
}

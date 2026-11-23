import 'package:mochi_stok/models/stock_record.dart';

export 'package:mochi_stok/models/stock_record.dart' show StockDirection;

/// Model transaksi pergerakan stok yang disinkronkan dengan tabel `stock_movements` di database MySQL.
class StockTransaction {
  const StockTransaction({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.unit,
    required this.direction,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    this.note = '',
    this.pathBuktiNota,
    required this.createdAt,
  });

  final int id;
  final int itemId;
  final String itemName;
  final String unit;
  final StockDirection direction;
  final double quantity;
  final double stockBefore;
  final double stockAfter;
  final String note;
  final String? pathBuktiNota;
  final DateTime createdAt;

  /// Memetakan response JSON dari API/Database ke objek Dart
  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: int.parse(json['id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      itemName: json['item_name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      direction: json['direction'] == 'keluar'
          ? StockDirection.keluar
          : StockDirection.masuk,
      quantity: double.tryParse(json['quantity'].toString()) ?? 0.0,
      stockBefore: double.tryParse(json['stock_before'].toString()) ?? 0.0,
      stockAfter: double.tryParse(json['stock_after'].toString()) ?? 0.0,
      note: json['note'] as String? ?? '',
      pathBuktiNota: json['path_bukti_nota'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Mengubah objek Dart ke payload JSON untuk dikirim ke API/Database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'item_name': itemName,
      'unit': unit,
      'direction': direction.name, // 'masuk' atau 'keluar'
      'quantity': quantity,
      'stock_before': stockBefore,
      'stock_after': stockAfter,
      'note': note,
      'path_bukti_nota': pathBuktiNota,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Konversi kompatibilitas balik ke StockRecord yang sudah ada di UI MochiStok
  StockRecord toStockRecord() {
    return StockRecord(
      id: id,
      time: createdAt,
      itemId: itemId,
      itemName: itemName,
      direction: direction,
      quantity: quantity,
      unit: unit,
      note: note,
      stockAfter: stockAfter,
    );
  }
}

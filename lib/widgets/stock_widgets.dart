import 'package:flutter/material.dart';
import 'package:mochi_stok/core/format.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/models/item.dart';
import 'package:mochi_stok/models/stock_record.dart';

// Pill kecil berwarna (Aman / Menipis / Habis / Masuk / Keluar).
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Pill status stok: warnanya mengikuti status item.
class StockStatusPill extends StatelessWidget {
  const StockStatusPill(this.status, {super.key});

  final StockStatus status;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (status) {
      StockStatus.aman => (MochiTheme.success, MochiTheme.successSoft),
      StockStatus.menipis => (MochiTheme.primary, MochiTheme.softPink),
      StockStatus.habis => (Colors.white, MochiTheme.primary),
    };
    return StatusPill(label: status.label, foreground: fg, background: bg);
  }
}

// Satu baris item: nama, kategori, batas minimum, jumlah stok, status, dan bar stok.
class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.item, this.onTap});

  final Item item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isOk = item.status == StockStatus.aman;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: MochiTheme.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.categoryName} · Min ${formatQuantity(item.minimum, item.unit)}',
                        style: const TextStyle(
                          color: MochiTheme.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatQuantity(item.stock, item.unit),
                      style: TextStyle(
                        color: isOk ? MochiTheme.ink : MochiTheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    StockStatusPill(item.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: item.progress,
                minHeight: 4,
                backgroundColor: MochiTheme.border,
                valueColor: AlwaysStoppedAnimation(
                  isOk ? MochiTheme.success : MochiTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Satu baris riwayat pencatatan: arah (masuk/keluar), nama item, waktu, jumlah, dan sisa stok setelahnya.
class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.record});

  final StockRecord record;

  @override
  Widget build(BuildContext context) {
    final isMasuk = record.direction == StockDirection.masuk;
    final qtyPrefix = isMasuk ? '+' : '-';
    final qtyColor = isMasuk ? MochiTheme.success : MochiTheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isMasuk ? MochiTheme.successSoft : MochiTheme.softPink,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMasuk ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
              color: qtyColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.itemName,
                  style: const TextStyle(
                    color: MochiTheme.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDateTime(record.time) +
                      (record.note.isNotEmpty ? ' · ${record.note}' : ''),
                  style: const TextStyle(
                    color: MochiTheme.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$qtyPrefix${formatQuantity(record.quantity, record.unit)}',
                style: TextStyle(
                  color: qtyColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Sisa: ${formatQuantity(record.stockAfter, record.unit)}',
                style: const TextStyle(
                  color: MochiTheme.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

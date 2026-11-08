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

// Satu baris item: nama, batas minimum, jumlah stok, status, dan bar stok.
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: MochiTheme.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Minimum ${formatQuantity(item.minimum, item.unit)}',
                        style: TextStyle(
                          color: isOk ? MochiTheme.muted : MochiTheme.primary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatQuantity(item.stock, item.unit),
                      style: const TextStyle(
                        color: MochiTheme.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    StockStatusPill(item.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: item.progress,
                minHeight: 4,
                backgroundColor:
                    isOk ? MochiTheme.successSoft : MochiTheme.border,
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

// Satu baris riwayat: nama item, waktu + catatan, jumlah, dan pill Masuk/Keluar.
class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.record});

  final StockRecord record;

  @override
  Widget build(BuildContext context) {
    final isIn = record.direction == StockDirection.masuk;
    final note = record.note.isEmpty ? '' : ' · ${record.note}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MochiTheme.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatDateTime(record.time)}$note',
                  style: const TextStyle(color: MochiTheme.muted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIn ? '+' : '−'}${formatQuantity(record.quantity, record.unit)}',
                style: const TextStyle(
                  color: MochiTheme.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              StatusPill(
                label: record.direction.label,
                foreground: isIn ? MochiTheme.success : MochiTheme.primary,
                background: isIn ? MochiTheme.successSoft : MochiTheme.softPink,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

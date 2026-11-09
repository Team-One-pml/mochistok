import 'package:flutter/material.dart';
import 'package:mochi_stok/core/format.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/data/inventory_store.dart';
import 'package:mochi_stok/models/item.dart';
import 'package:mochi_stok/widgets/mochi_card.dart';
import 'package:mochi_stok/widgets/stock_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.onViewAll, this.onRestock});

  // Callback ini diteruskan ke tombol "Semua" agar navigasi ditentukan oleh parent.
  final VoidCallback? onViewAll;
  // Dipanggil saat item di daftar "Perlu diisi ulang" diketuk.
  final ValueChanged<Item>? onRestock;

  @override
  Widget build(BuildContext context) {
    // Data diambil dari store, jadi otomatis ikut berubah saat stok dicatat.
    final store = InventoryScope.of(context);
    final lowItems = store.lowStockItems;
    final recent = store.history.take(3).toList();

    // SafeArea mencegah konten tertutup status bar; ListView membuat halaman bisa digulir.
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text(
            formatDateLong(DateTime.now()),
            style: const TextStyle(
              color: MochiTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Halo, Admin',
            style: TextStyle(
              color: MochiTheme.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  count: '${store.items.length}',
                  title: 'Jenis item',
                  isHighlighted: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  count: '${lowItems.length}',
                  title: 'Stok menipis',
                  // Kartu hanya menyala pink kalau memang ada yang menipis.
                  isHighlighted: lowItems.isNotEmpty,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MochiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perlu diisi ulang',
                  style: TextStyle(
                    color: MochiTheme.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Divider(color: MochiTheme.border, height: 8),
                if (lowItems.isEmpty)
                  const _EmptyNote('Semua stok di atas batas minimum.')
                else
                  ...withDividers([
                    for (final item in lowItems)
                      ItemTile(
                        item: item,
                        onTap: onRestock == null
                            ? null
                            : () => onRestock!(item),
                      ),
                  ]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MochiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Terakhir dicatat',
                        style: TextStyle(
                          color: MochiTheme.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onViewAll,
                      style: TextButton.styleFrom(
                        foregroundColor: MochiTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Semua',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: MochiTheme.border, height: 8),
                if (recent.isEmpty)
                  const _EmptyNote('Belum ada pencatatan stok.')
                else
                  ...withDividers([
                    for (final record in recent) HistoryTile(record: record),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Kartu ringkasan dipisahkan menjadi widget agar bisa digunakan ulang dengan isi berbeda.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.count,
    required this.title,
    required this.isHighlighted,
  });

  final String count;
  final String title;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        // Warna kartu berubah untuk menonjolkan informasi yang perlu diperhatikan.
        color: isHighlighted ? MochiTheme.softPink : Colors.white,
        border: isHighlighted ? null : Border.all(color: MochiTheme.border),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              color: isHighlighted ? MochiTheme.primary : MochiTheme.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              color: isHighlighted ? MochiTheme.primary : MochiTheme.ink,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: MochiTheme.muted, fontSize: 12),
        ),
      ),
    );
  }
}

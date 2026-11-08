import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/data/inventory_store.dart';
import 'package:mochi_stok/widgets/mochi_card.dart';
import 'package:mochi_stok/widgets/page_header.dart';
import 'package:mochi_stok/widgets/stock_widgets.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = InventoryScope.of(context).history;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          PageHeader(title: 'Riwayat', subtitle: '${history.length} pencatatan'),
          const SizedBox(height: 14),
          MochiCard(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
            child: history.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Belum ada pencatatan stok.',
                        style: TextStyle(color: MochiTheme.muted, fontSize: 12),
                      ),
                    ),
                  )
                : Column(
                    children: withDividers([
                      for (final record in history) HistoryTile(record: record),
                    ]),
                  ),
          ),
        ],
      ),
    );
  }
}
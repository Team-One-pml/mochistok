import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/data/inventory_store.dart';
import 'package:mochi_stok/features/items/item_form_sheet.dart';
import 'package:mochi_stok/models/item.dart';
import 'package:mochi_stok/widgets/form_widgets.dart';
import 'package:mochi_stok/widgets/mochi_card.dart';
import 'package:mochi_stok/widgets/page_header.dart';
import 'package:mochi_stok/widgets/stock_widgets.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  ItemType _filter = ItemType.bahan;
  String _query = '';

  Future<void> _openForm(InventoryStore store, {Item? item}) async {
    final result = await showModalBottomSheet<(String, ItemType)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 480),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ItemFormSheet(
        store: store,
        item: item,
        initialType: _filter,
      ),
    );

    if (!mounted || result == null) return;
    setState(() => _filter = result.$2); // pindah ke tab jenis item tadi
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.$1)));
  }

  @override
  Widget build(BuildContext context) {
    final store = InventoryScope.of(context);
    final query = _query.trim().toLowerCase();
    final list = store.items
        .where((i) =>
            i.type == _filter &&
            (query.isEmpty || i.name.toLowerCase().contains(query)))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(store),
        tooltip: 'Tambah item',
        backgroundColor: MochiTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 88),
          children: [
            const PageHeader(
              title: 'Item',
              subtitle: 'Bahan baku dan mochi jadi',
            ),
            const SizedBox(height: 14),
            MochiSegmented<ItemType>(
              options: {for (final t in ItemType.values) t: t.label},
              value: _filter,
              onChanged: (type) => setState(() => _filter = type),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Cari nama item',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            MochiCard(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
              child: list.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Tidak ada item. Tekan + untuk menambah.',
                          style: TextStyle(color: MochiTheme.muted, fontSize: 12),
                        ),
                      ),
                    )
                  : Column(
                      children: withDividers([
                        for (final item in list)
                          ItemTile(
                            item: item,
                            onTap: () => _openForm(store, item: item),
                          ),
                      ]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

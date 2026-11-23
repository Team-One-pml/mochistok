import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/data/inventory_store.dart';
import 'package:mochi_stok/features/items/item_form_sheet.dart';
import 'package:mochi_stok/models/category.dart';
import 'package:mochi_stok/models/item.dart';
import 'package:mochi_stok/widgets/mochi_card.dart';
import 'package:mochi_stok/widgets/page_header.dart';
import 'package:mochi_stok/widgets/stock_widgets.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  int? _selectedCategoryId; // null = Tampilkan Semua
  String _query = '';

  Future<void> _openForm(InventoryStore store, {Item? item}) async {
    final result = await showModalBottomSheet<(String, int)>(
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
        initialCategoryId: _selectedCategoryId,
      ),
    );

    if (!mounted || result == null) return;
    setState(() => _selectedCategoryId = result.$2);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.$1)));
  }

  Future<void> _dialogAddCategory(InventoryStore store) async {
    final catController = TextEditingController();
    final newCat = await showDialog<Category?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Kategori Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: catController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Contoh: Kemasan Khusus / Pewarna',
            labelText: 'Nama Kategori',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final text = catController.text.trim();
              if (text.isEmpty) return;
              final created = store.addCategory(text);
              Navigator.pop(ctx, created);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (newCat != null && mounted) {
      setState(() => _selectedCategoryId = newCat.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = InventoryScope.of(context);
    final categories = store.categories;
    final query = _query.trim().toLowerCase();

    final list = store.items.where((i) {
      final matchCategory = _selectedCategoryId == null || i.categoryId == _selectedCategoryId;
      final matchQuery = query.isEmpty ||
          i.name.toLowerCase().contains(query) ||
          i.sku.toLowerCase().contains(query);
      return matchCategory && matchQuery;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(store),
        tooltip: 'Tambah bahan baku',
        backgroundColor: MochiTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 88),
          children: [
            const PageHeader(
              title: 'Bahan Baku',
              subtitle: 'Manajemen persediaan bahan & kemasan mochi',
            ),
            const SizedBox(height: 14),
            // Baris Kategori Dinamis dengan tombol tambah kategori
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _selectedCategoryId == null,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategoryId = null);
                    },
                  ),
                  const SizedBox(width: 8),
                  for (final cat in categories) ...[
                    ChoiceChip(
                      label: Text(cat.name),
                      selected: _selectedCategoryId == cat.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected ? cat.id : null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: const Text('Kategori'),
                    onPressed: () => _dialogAddCategory(store),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Cari nama bahan atau SKU...',
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
                          'Tidak ada bahan. Tekan + untuk menambah.',
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

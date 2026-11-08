import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/data/inventory_store.dart';
import 'package:mochi_stok/features/auth/login_page.dart';

void main() {
  // InventoryScope dipasang di paling atas supaya semua halaman
  // (Beranda, Item, Stok, Riwayat) memakai data yang sama.
  runApp(
    InventoryScope(
      store: InventoryStore(),
      child: const MochiStokApp(),
    ),
  );
}

class MochiStokApp extends StatelessWidget {
  const MochiStokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mochi Stock',
      debugShowCheckedModeBanner: false,
      theme: MochiTheme.light,
      home: const LoginPage(),
    );
  }
}

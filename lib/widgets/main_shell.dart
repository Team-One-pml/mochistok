import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/features/history/history_page.dart';
import 'package:mochi_stok/features/home/home_page.dart';
import 'package:mochi_stok/features/items/items_page.dart';
import 'package:mochi_stok/features/stock/stock_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  // Item yang langsung dipilih di tab Stok (dipakai kalau nanti ada tombol isi ulang dari Beranda).
  int? _restockItemId;

  static const _destinations = [
    _NavigationDestinationData(
      label: 'Beranda',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_outlined,
    ),
    _NavigationDestinationData(
      label: 'Item',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_outlined,
    ),
    _NavigationDestinationData(
      label: 'Stok',
      icon: Icons.swap_horiz,
      selectedIcon: Icons.swap_horiz,
    ),
    _NavigationDestinationData(
      label: 'Riwayat',
      icon: Icons.access_time,
      selectedIcon: Icons.access_time,
    ),
  ];

  void _goTo(int index) {
    setState(() {
      _selectedIndex = index;
      _restockItemId = null;
    });
  }

  Widget _buildPage() {
    return switch (_selectedIndex) {
      0 => HomePage(onViewAll: () => _goTo(3)),
      1 => const ItemsPage(),
      2 => StockPage(
          key: ValueKey(_restockItemId),
          initialItemId: _restockItemId,
          onSaved: () => _goTo(0),
        ),
      _ => const HistoryPage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Di layar lebar (browser desktop) tampilan dibatasi seperti layar HP di tengah.
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F4),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: MochiTheme.outline),
              ),
            ),
            child: Scaffold(
              body: _buildPage(),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _goTo,
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xFFFFE6EB),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  for (final destination in _destinations)
                    NavigationDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: destination.label,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationDestinationData {
  const _NavigationDestinationData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
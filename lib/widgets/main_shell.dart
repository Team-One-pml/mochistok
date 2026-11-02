import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/features/home/home_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? HomePage(onViewAll: () => setState(() => _selectedIndex = 3))
          : _ComingSoonPage(title: _destinations[_selectedIndex].label),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
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

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          '$title segera hadir',
          style: const TextStyle(
            color: MochiTheme.muted,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

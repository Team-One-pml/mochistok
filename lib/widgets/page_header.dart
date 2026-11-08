import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';

// Judul halaman (Item, Catat stok, Riwayat) agar tampilannya seragam.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: MochiTheme.ink,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: MochiTheme.muted, fontSize: 12),
        ),
      ],
    );
  }
}

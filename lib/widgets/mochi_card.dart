import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';

// Kartu putih dengan garis pink, dipakai di Beranda, Item, dan Riwayat.
class MochiCard extends StatelessWidget {
  const MochiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(13, 12, 13, 10),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MochiTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

// Menyisipkan garis pemisah di antara baris, tanpa garis setelah baris terakhir.
List<Widget> withDividers(List<Widget> children) => [
      for (var i = 0; i < children.length; i++) ...[
        children[i],
        if (i < children.length - 1)
          const Divider(color: MochiTheme.border, height: 1, thickness: 0.6),
      ],
    ];

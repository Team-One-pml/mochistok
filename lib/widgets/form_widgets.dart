import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';

// Label kecil berwarna pink di atas kolom input (sama seperti halaman login).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        label,
        style: const TextStyle(
          color: MochiTheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Pilihan dua/lebih opsi dalam satu baris (Bahan baku | Mochi jadi, dll).
class MochiSegmented<T> extends StatelessWidget {
  const MochiSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        segments: [
          for (final entry in options.entries)
            ButtonSegment<T>(value: entry.key, label: Text(entry.value)),
        ],
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.first),
        style: SegmentedButton.styleFrom(
          foregroundColor: MochiTheme.muted,
          selectedForegroundColor: MochiTheme.primary,
          selectedBackgroundColor: MochiTheme.softPink,
          side: const BorderSide(color: MochiTheme.border),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

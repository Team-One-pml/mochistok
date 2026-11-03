import 'package:flutter/material.dart';

// Kumpulan warna dan gaya global agar tampilan aplikasi tetap konsisten
abstract final class MochiTheme {
  // Warna utama digunakan untuk tombol dan elemen yang perlu ditonjolkan
  static const Color primary = Color(0xFFFF2854);
  // Warna teks utama, teks sekunder, dan garis komponen
  static const Color ink = Color(0xFF202B27);
  static const Color muted = Color(0xFF78817D);
  static const Color outline = Color(0xFFE5EAE7);

  // Tema terang menjadi sumber gaya dasar yang dipakai oleh seluruh aplikasi
  static ThemeData get light {
    // ColorScheme dibuat dari warna utama agar komponen Material selaras
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(bodyMedium: TextStyle(color: ink)),
      // Pengaturan ini membuat semua input memiliki padding dan bentuk seragam
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        hintStyle: const TextStyle(color: muted, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: primary),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
    );
  }
}

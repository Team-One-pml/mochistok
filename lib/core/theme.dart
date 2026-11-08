import 'package:flutter/material.dart';

// Kumpulan warna dan gaya global agar tampilan aplikasi tetap konsisten
abstract final class MochiTheme {
  // Warna utama digunakan untuk tombol dan elemen yang perlu ditonjolkan
  static const Color primary = Color(0xFFFF2854);
  // Warna teks utama, teks sekunder, dan garis komponen
  static const Color ink = Color(0xFF202B27);
  static const Color muted = Color(0xFF78817D);
  static const Color outline = Color(0xFFE5EAE7);

  // Warna tambahan yang sebelumnya ditulis berulang di home_page.dart
  static const Color border = Color(0xFFFFA9BA); // garis kartu bernuansa pink
  static const Color softPink = Color(0xFFFFD8E0); // latar kartu/pill yang menonjol
  // Warna status "Aman"
  static const Color success = Color(0xFF2E7A4A);
  static const Color successSoft = Color(0xFFE0F2E6);

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
      // Semua FilledButton otomatis memakai gaya ini
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
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

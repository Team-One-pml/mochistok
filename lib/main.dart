import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';
import 'package:mochi_stok/features/auth/login_page.dart';

void main() {
  runApp(const MochiStokApp());
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

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mochi_stok/features/home/home_page.dart';
import 'package:mochi_stok/features/auth/login_page.dart';
import 'package:mochi_stok/main.dart';
import 'package:mochi_stok/widgets/main_shell.dart';

void main() {
  testWidgets('shows Mochi Stock login page', (WidgetTester tester) async {
    await tester.pumpWidget(const MochiStokApp());

    expect(find.text('Mochi Stock'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('validates empty login fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Username wajib diisi.'), findsOneWidget);
    expect(find.text('Password wajib diisi.'), findsOneWidget);
  });

  testWidgets('shows home dashboard after login', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('Halo, Admin'), findsOneWidget);
    expect(find.text('Perlu diisi ulang'), findsOneWidget);
    expect(find.text('Mochi matcha'), findsOneWidget);
  });

  testWidgets('home navigation switches to other tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));

    expect(find.byType(HomePage), findsOneWidget);
    await tester.tap(find.text('Item'));
    await tester.pumpAndSettle();

    expect(find.text('Item segera hadir'), findsOneWidget);
  });
}

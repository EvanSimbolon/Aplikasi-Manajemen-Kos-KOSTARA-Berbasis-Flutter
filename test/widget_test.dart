import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:belajar_dart/config/app.dart';
import 'package:belajar_dart/ui/kalender/widgets/kalender_screen.dart';

void main() {
  testWidgets('Landing screen renders', (WidgetTester tester) async {
    // Memastikan widget utama dijalankan
    await tester.pumpWidget(const KostaraApp());

    // Mengecek teks selamat datang
    expect(find.text('Selamat datang di KOSTARA'), findsOneWidget);
  });

  testWidgets('Kalender screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: KalenderScreen(),
      ),
    );

    expect(find.byType(KalenderScreen), findsOneWidget);
  });
}

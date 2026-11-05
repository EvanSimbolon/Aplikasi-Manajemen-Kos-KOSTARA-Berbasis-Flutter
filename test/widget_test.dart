import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:belajar_dart/config/app.dart';
import 'package:belajar_dart/ui/dashboard/widgets/dashboard_screen.dart';
import 'package:belajar_dart/ui/kalender/widgets/kalender_screen.dart';
import 'package:belajar_dart/ui/maintenance/widgets/maintenance_screen.dart';
import 'package:belajar_dart/ui/profil/widgets/admin_profil_screen.dart';

void main() {
  testWidgets('Landing screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const KostaraApp());

    expect(find.text('Selamat datang di KOSTARA'), findsOneWidget);
    expect(find.text('Penghuni Kos'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });

  testWidgets('Dashboard screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardPage()));

    expect(find.text('HALO Penghuni'), findsOneWidget);
    expect(find.text('Rp 1.000.000'), findsOneWidget);
    expect(find.text('Kamar A01'), findsOneWidget);
  });

  testWidgets('Maintenance screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MaintenancePage()));

    expect(find.text('Maintenance'), findsWidgets);
    expect(find.text('#001 - AC Bocor'), findsOneWidget);
    expect(find.text('Status : Selesai'), findsOneWidget);
  });

  testWidgets('Kalender screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: KalenderPage()));

    expect(find.text('Kalender'), findsOneWidget);
    expect(find.byKey(const Key('calendar-title')), findsOneWidget);
    expect(find.text('Jatuh Tempo Pembayaran'), findsWidgets);
  });

  testWidgets('Profil admin screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilPage()));

    expect(find.text('Profil'), findsWidgets);
    expect(find.text('Dion Prayoga'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
  });
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_dashboard/main.dart';

void main() {
  testWidgets('Dashboard satu kolom di layar sempit', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    final cards = find.byType(InfoCard);
    expect(cards, findsNWidgets(4));
    expect(tester.getCenter(cards.at(0)).dx, tester.getCenter(cards.at(1)).dx);
    expect(
      tester.getCenter(cards.at(0)).dy,
      lessThan(tester.getCenter(cards.at(1)).dy),
    );
  });

  testWidgets('Dashboard dua kolom di layar lebar', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    final cards = find.byType(InfoCard);
    expect(cards, findsNWidgets(4));
    expect(tester.getCenter(cards.at(0)).dy, tester.getCenter(cards.at(1)).dy);
    expect(
      tester.getCenter(cards.at(0)).dx,
      lessThan(tester.getCenter(cards.at(1)).dx),
    );
  });

  testWidgets('CupertinoSwitch mengganti tema', (tester) async {
    await tester.pumpWidget(const DashboardApp());
    expect(
      Theme.of(tester.element(find.byType(DashboardPage))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(DashboardPage))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('kartu memiliki label aksesibilitas', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const DashboardApp());

    expect(find.bySemanticsLabel('Assignments: 8'), findsOneWidget);
    expect(find.bySemanticsLabel('Attendance: 92%'), findsOneWidget);
    semantics.dispose();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/main.dart';
import 'package:week3_todo/providers/stats_provider.dart';
import 'package:week3_todo/router.dart';

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(child: MyApp(router: router)));
    expect(find.text('Belum ada tugas'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();
    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });

  testWidgets('berpindah ke halaman statistik dengan GoRouter', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(randomValue: () => 0.9, delay: Duration.zero),
          ),
        ],
        child: MyApp(router: router),
      ),
    );
    await tester.tap(find.text('Statistik'));
    await tester.pump();
    expect(router.routeInformationProvider.value.uri.path, '/stats');
    expect(find.text('Statistik Asinkron'), findsOneWidget);
  });
}

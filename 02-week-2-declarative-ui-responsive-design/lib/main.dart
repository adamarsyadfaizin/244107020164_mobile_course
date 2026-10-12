import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const kWideBreakpoint = 700.0;

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    darkTheme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.indigo,
    ),
    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    home: DashboardPage(
      isDark: isDark,
      onDarkChanged: (value) => setState(() => isDark = value),
    ),
  );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.isDark,
    required this.onDarkChanged,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Academic Overview'),
      actions: [
        Semantics(
          label: 'Tema gelap',
          toggled: isDark,
          child: CupertinoSwitch(value: isDark, onChanged: onDarkChanged),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= kWideBreakpoint ? 2 : 1;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(child: Text('A')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Moch. Adam Arsyad Faizin',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Text('NIM 244107020164'),
                          const Text('TI-3F'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.6,
                children: const [
                  InfoCard(title: 'Assignments', value: '8'),
                  InfoCard(title: 'Attendance', value: '92%'),
                  InfoCard(title: 'Portfolio', value: 'Ready'),
                  InfoCard(title: 'Current week', value: '02'),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$title: $value',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    ),
  );
}

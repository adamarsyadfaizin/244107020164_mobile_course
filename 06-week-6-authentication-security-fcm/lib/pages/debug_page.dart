import 'package:flutter/material.dart';

import '../messaging/push_service.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Debug FCM')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: const Text('FCM token'),
            subtitle: ValueListenableBuilder<String?>(
              valueListenable: tokenPreview,
              builder: (context, token, child) => token == null
                  ? const LinearProgressIndicator()
                  : SelectableText(token),
            ),
          ),
        ),
      ],
    ),
  );
}

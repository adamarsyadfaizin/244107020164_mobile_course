import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'messaging/push_service.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  registerBackgroundHandler();
  await initLocalNotifications();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_startMessaging());
    });
  }

  Future<void> _startMessaging() async {
    void go(String route) {
      if (mounted) ref.read(routerProvider).go(route);
    }

    listenForeground(go);
    await handleTerminated(go);
    try {
      if (await requestNotificationPermission()) {
        await initFcmToken(onToken: uploadDeviceToken);
      } else {
        tokenPreview.value = 'Tidak tersedia';
      }
    } catch (_) {
      tokenPreview.value = 'Tidak tersedia';
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Campus Notify',
    routerConfig: ref.watch(routerProvider),
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
  );
}

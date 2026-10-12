import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routes.dart';

const _backendUrl = String.fromEnvironment('FCM_BACKEND_URL');
const _topic = 'pengumuman-kampus';
final _local = FlutterLocalNotificationsPlugin();
final tokenPreview = ValueNotifier<String?>(null);
StreamSubscription<String>? _tokenRefreshSubscription;
void Function(String route)? _navigate;
bool _listening = false;
String? pendingDeepLink;

// Background messages run in a separate isolate; do not use UI or Riverpod.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      final route = response.payload;
      if (route == null || route.isEmpty) return;
      if (_navigate != null) {
        _navigate!(route);
      } else {
        pendingDeepLink = route;
      }
    },
  );
  final launch = await _local.getNotificationAppLaunchDetails();
  if (launch?.didNotificationLaunchApp == true) {
    pendingDeepLink = launch?.notificationResponse?.payload;
  }
}

Future<void> uploadDeviceToken(String token) async {
  final visibleLength = token.length < 12 ? token.length : 12;
  tokenPreview.value = '${token.substring(0, visibleLength)}...';
  if (_backendUrl.isEmpty) return;

  final dio = Dio(
    BaseOptions(
      baseUrl: _backendUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  try {
    await dio.post<Object?>(
      '/devices',
      data: {
        'fcm_token': token,
        'platform': defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
      },
    );
  } on DioException {
    // The token preview remains available; backend delivery needs verification.
  }
}

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);

  await _tokenRefreshSubscription?.cancel();
  _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
    (token) => unawaited(onToken(token)),
  );
  await FirebaseMessaging.instance.subscribeToTopic(_topic);
}

Future<void> unsubscribeFromCampusTopic() =>
    FirebaseMessaging.instance.unsubscribeFromTopic(_topic);

void listenForeground(void Function(String route) go) {
  _navigate = go;
  if (_listening) return;
  _listening = true;

  FirebaseMessaging.onMessage.listen((message) async {
    const androidDetails = AndroidNotificationDetails(
      'pengumuman',
      'Pengumuman Kampus',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
      payload: routeFromMessage(message.data),
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    _navigate?.call(routeFromMessage(message.data));
  });
}

Future<void> handleTerminated(void Function(String route) go) async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    go(routeFromMessage(initial.data));
    return;
  }
  final route = pendingDeepLink;
  pendingDeepLink = null;
  if (route != null) go(route);
}

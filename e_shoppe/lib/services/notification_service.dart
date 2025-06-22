import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState>? _navKey;

  static const _promoTopic = 'promotions';
  static const _prefKey = 'promo_subscribed';

  Future<void> init(GlobalKey<NavigatorState> navKey) async {
    _navKey = navKey;

    await _messaging.requestPermission();

    // Initialise local notifications (required for iOS foreground alerts)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        if (payload != null && _navKey?.currentState != null) {
          _navKey!.currentState!.pushNamed(payload);
        }
      },
    );

    await _local.initialize(
      InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (resp) {
        final payload = resp.payload;
        if (payload != null) {
          _handleLink(payload);
        }
      },
    );

    // Foreground
    FirebaseMessaging.onMessage.listen(_onMessage);

    // When user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    // App launched from terminated state via notification
    final initialMsg = await _messaging.getInitialMessage();
    if (initialMsg != null) {
      _onMessageOpened(initialMsg);
    }
  }

  void _onMessage(RemoteMessage msg) {
    final title = msg.notification?.title ?? 'Notification';
    final body = msg.notification?.body ?? '';

    // Show a local notification so the user sees an alert when app is in foreground.
    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        'default',
        'Default',
        channelDescription: 'General notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      ),
      iOS: DarwinNotificationDetails(
        attachments: msg.notification?.apple?.imageUrl != null
            ? [DarwinNotificationAttachment(msg.notification!.apple!.imageUrl!)]
            : null,
      ),
    );

    final link = msg.data['link'] ?? msg.data['route'];

    _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: link,
    );
  }

  void _onMessageOpened(RemoteMessage msg) {
    final link = msg.data['link'] ?? msg.data['route'];
    if (link != null) _handleLink(link);
  }

  void _handleLink(String link) async {
    if (_navKey == null) return;
    final uri = Uri.tryParse(link);
    if (uri == null) return;

    // External http/https links
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // Internal route with optional query parameters.
    final routePath = uri.path.isEmpty ? link : uri.path;
    _navKey!.currentState!.pushNamed(routePath,
        arguments: uri.queryParameters.isEmpty ? null : uri.queryParameters);
  }

  Future<bool> isPromoSubscribed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  Future<void> setPromoSubscription(bool subscribe) async {
    final prefs = await SharedPreferences.getInstance();
    if (subscribe) {
      await _messaging.subscribeToTopic(_promoTopic);
    } else {
      await _messaging.unsubscribeFromTopic(_promoTopic);
    }
    await prefs.setBool(_prefKey, subscribe);
  }
}

// Must be a top-level function for background handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // You can perform background processing here (e.g., data sync).
}

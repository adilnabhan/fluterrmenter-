import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/core/api/uris/api_uris.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    if (message.notification == null) {
      final title = message.data['title'] ?? 'Discipl';
      final body = message.data['body'] ?? message.data['message'];
      if (body != null && body.toString().isNotEmpty) {
        final localNotifications = FlutterLocalNotificationsPlugin();
        const initSettings = InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        );
        await localNotifications.initialize(settings: initSettings);
        await localNotifications.show(
          id: message.hashCode,
          title: title,
          body: body.toString(),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'This channel is used for important notifications.',
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
              playSound: true,
              enableVibration: true,
            ),
          ),
        );
      }
    }
  } catch (_) {}
}

class NotificationServices {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('🔔 FCM permission status: ${settings.authorizationStatus}');

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_channel);
      await androidPlugin?.requestNotificationsPermission();

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _localNotifications.initialize(settings: initSettings);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📩 Foreground FCM received: ${message.messageId}');
        final notification = message.notification;
        final title = notification?.title ?? message.data['title'] ?? 'Discipl';
        final body = notification?.body ?? message.data['body'] ?? message.data['message'];

        if (body != null && body.toString().isNotEmpty) {
          _localNotifications.show(
            id: message.hashCode,
            title: title,
            body: body.toString(),
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                icon: '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
                showWhen: true,
                playSound: true,
                enableVibration: true,
              ),
            ),
          );
        }
      });

      _isInitialized = true;
      await registerDeviceToken();

      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        registerDeviceToken();
      });
    } catch (e) {
      debugPrint('❌ NotificationServices init error: $e');
    }
  }

  static Future<void> registerDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('📱 FCM Device Token: $token');
      if (token != null) {
        await DioClient().dio.post(
          ApiUris.registerDeviceToken,
          data: {
            'token': token,
            'platform': Platform.isAndroid ? 'android' : 'ios',
          },
        );
        debugPrint('✅ Device token registered successfully with backend');
      }
    } catch (e) {
      debugPrint('⚠️ Device token registration failed: $e');
    }
  }
}

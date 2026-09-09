import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mentor_mobile_app/core/api/uris/api_uris.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (_) {
        await Firebase.initializeApp();
      }
    }
  } catch (_) {}
  // Background notifications with `notification` payload are automatically 
  // rendered by the OS in the phone notification centre.
}

class NotificationServices {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // Matches channel_id in apps/communication/notifications.py
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } catch (_) {
          await Firebase.initializeApp();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Firebase initialization failed (needs full app rebuild): $e');
      }
      return;
    }

    // 1. Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Request OS permissions (Shows the iOS/Android 13 permission popup)
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // 3. Create Android Notification Channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // 4. Configure iOS foreground heads-up presentation
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 5. Initialize local notifications for foreground popups
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          if (kDebugMode) {
            print('🔔 Notification clicked: ${details.payload}');
          }
        },
      );

      // 6. Handle foreground notifications (App is open)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        final android = message.notification?.android;
        if (notification != null) {
          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                icon: android?.smallIcon ?? '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: message.data.toString(),
          );
        }
      });

      // Handle notification open when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('🔔 App opened from notification: ${message.data}');
        }
      });

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((_) {
        registerDeviceToken();
      });

      // 7. Get token and send to backend
      await registerDeviceToken();
    }
  }

  /// Sends the device token to your Django endpoint
  static Future<void> registerDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        if (kDebugMode) {
          print('🔑 FCM Device Token: $token');
        }
        await DioClient().dio.post<dynamic>(
          ApiUris.registerDeviceToken,
          data: {
            'token': token,
            'platform': Platform.isAndroid ? 'android' : 'ios',
          },
        );
        if (kDebugMode) {
          print('✅ Device token registered with backend successfully');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to register device token: $e');
      }
    }
  }
}

/// Alias so both NotificationService and NotificationServices work
typedef NotificationService = NotificationServices;

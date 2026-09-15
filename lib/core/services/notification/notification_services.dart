import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/api/uris/api_uris.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/core/storage/local_storage_service.dart';
import 'package:mentor_mobile_app/firebase_options.dart';
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_notifications_screen.dart';

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

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
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

    // 2. Create Android Notification Channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 3. Initialize local notifications for foreground popups
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
        Feggy.navKey.currentState?.push(
          MaterialPageRoute<void>(
            builder: (context) => const TrainerNotificationsScreen(),
          ),
        );
      },
    );

    // 4. Handle foreground notifications (App is open)
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
      Feggy.navKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (context) => const TrainerNotificationsScreen(),
        ),
      );
    });

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      registerDeviceToken();
    });

    _isInitialized = true;
  }

  /// Requests notification permission from the OS (iOS & Android 13+)
  /// and registers the device token with the backend if granted.
  /// Called after login or when an authenticated session is active.
  static Future<void> requestPermissionAndRegisterToken() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();

      if (kDebugMode) {
        print('🔔 Notification authorization status: ${settings.authorizationStatus}');
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Configure iOS foreground presentation options
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // Register token with backend
        await registerDeviceToken();
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error requesting notification permission: $e');
      }
    }
  }

  /// Alias for backward compatibility
  static Future<void> requestPermission() async {
    await requestPermissionAndRegisterToken();
  }

  /// Sends the device token to your Django endpoint (only when user is authenticated)
  static Future<void> registerDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && kDebugMode) {
        print('🔑 FCM Device Token: $token');
      }

      // Check if user is authenticated before sending token to backend
      final user = LocalStorageService().getUser();
      final accessToken = user?.access;
      if (accessToken == null || accessToken.isEmpty) {
        if (kDebugMode) {
          print('ℹ️ No authenticated user yet; skipping backend device token registration until login.');
        }
        return;
      }

      if (token != null) {
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

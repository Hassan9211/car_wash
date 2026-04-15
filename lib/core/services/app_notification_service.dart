import 'dart:io';

import 'package:car_wash/core/services/otp_email_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background message handler — must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await AppNotificationService.showLocalNotification(
    title: message.notification?.title ?? 'CarWash',
    body: message.notification?.body ?? '',
  );
}

class AppNotificationService {
  AppNotificationService._();

  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static const _channelId = 'carwash_channel';
  static const _channelName = 'CarWash Notifications';

  static Future<void> initialize() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications setup
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              importance: Importance.high,
            ),
          );
    }

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        showLocalNotification(
          title: notification.title ?? 'CarWash',
          body: notification.body ?? '',
        );
      }
    });
  }

  /// Shows a local push notification on the device.
  static Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Sends a booking notification — push + email.
  static Future<void> sendBookingNotification({
    required String providerEmail,
    required String providerName,
    required String customerName,
    required String serviceType,
    required String bookingTime,
  }) async {
    // Local push to provider (if they are on this device)
    await showLocalNotification(
      title: 'New Booking!',
      body: '$customerName booked $serviceType at $bookingTime',
    );

    // Email notification to provider
    try {
      await OtpEmailService.sendBookingNotificationEmail(
        toEmail: providerEmail,
        providerName: providerName,
        customerName: customerName,
        serviceType: serviceType,
        bookingTime: bookingTime,
      );
    } catch (_) {
      // Email failure should not block the booking flow
    }
  }

  /// Get FCM token for this device (useful for server-side push).
  static Future<String?> getFcmToken() async {
    return FirebaseMessaging.instance.getToken();
  }
}

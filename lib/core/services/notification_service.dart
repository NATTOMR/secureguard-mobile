import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

/// Top-level background message handler required by FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[NotificationService] Background message received: ${message.messageId}');
  debugPrint('[NotificationService] Data: ${message.data}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  final _notificationStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onNotificationReceived => _notificationStreamController.stream;

  /// Initializes push notification channels, permissions, and FCM message streams.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Request Runtime Notification Permissions (Android 13+ & iOS)
      await _requestPermissions();

      // 2. Safely initialize Firebase if configured
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
        }
      } catch (e) {
        debugPrint('[NotificationService] Firebase not initialized or config missing: $e');
      }

      if (Firebase.apps.isNotEmpty) {
        final messaging = FirebaseMessaging.instance;

        // Set background message handler
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // Foreground notification options for iOS / Android
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // Fetch initial device token
        try {
          _fcmToken = await messaging.getToken();
          debugPrint('[NotificationService] FCM Token registered: $_fcmToken');
        } catch (e) {
          debugPrint('[NotificationService] Could not retrieve FCM token: $e');
        }

        // Listen for token refreshes
        messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('[NotificationService] FCM Token refreshed: $newToken');
        });

        // 3. Foreground Message Listener
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('[NotificationService] Foreground Push: ${message.notification?.title}');
          final payload = {
            'title': message.notification?.title ?? message.data['title'] ?? 'Security Alert',
            'body': message.notification?.body ?? message.data['body'] ?? '',
            'data': message.data,
            'source': message.data['source'] ?? 'FCM Push',
            'severity': message.data['severity'] ?? 'medium',
            'timestamp': DateTime.now().toIso8601String(),
          };
          _notificationStreamController.add(payload);
        });

        // 4. Handle Notification click when app opened from background
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('[NotificationService] App opened via notification: ${message.data}');
          _notificationStreamController.add({
            'opened_from_tap': true,
            'title': message.notification?.title ?? message.data['title'] ?? 'Security Alert',
            'data': message.data,
          });
        });

        // 5. Default Subscribe to core security topics
        await subscribeToThreatAlerts();
      }

      _isInitialized = true;
      debugPrint('[NotificationService] Notification Service successfully initialized.');
    } catch (e) {
      debugPrint('[NotificationService] NotificationService initialization failed: $e');
    }
  }

  /// Request Notification permissions
  Future<bool> _requestPermissions() async {
    try {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        debugPrint('[NotificationService] Notification permission granted.');
        return true;
      } else {
        debugPrint('[NotificationService] Notification permission status: $status');
        return false;
      }
    } catch (e) {
      debugPrint('[NotificationService] Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Subscribe to SIEM / SAST threat notification topics
  Future<void> subscribeToThreatAlerts() async {
    if (Firebase.apps.isEmpty) return;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.subscribeToTopic('soc_critical');
      await messaging.subscribeToTopic('wazuh_alerts');
      await messaging.subscribeToTopic('semgrep_findings');
      debugPrint('[NotificationService] Subscribed to enterprise threat alert topics.');
    } catch (e) {
      debugPrint('[NotificationService] Topic subscription failed: $e');
    }
  }

  /// Unsubscribe from alert topics
  Future<void> unsubscribeFromThreatAlerts() async {
    if (Firebase.apps.isEmpty) return;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.unsubscribeFromTopic('soc_critical');
      await messaging.unsubscribeFromTopic('wazuh_alerts');
      await messaging.unsubscribeFromTopic('semgrep_findings');
      debugPrint('[NotificationService] Unsubscribed from threat alert topics.');
    } catch (e) {
      debugPrint('[NotificationService] Unsubscribe failed: $e');
    }
  }

  /// Broadcast a simulated or in-app custom notification event
  void dispatchLocalNotification({
    required String title,
    required String body,
    String severity = 'critical',
    String source = 'Wazuh SOC',
    Map<String, dynamic>? extraData,
  }) {
    _notificationStreamController.add({
      'title': title,
      'body': body,
      'severity': severity,
      'source': source,
      'data': extraData ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void dispose() {
    _notificationStreamController.close();
  }
}

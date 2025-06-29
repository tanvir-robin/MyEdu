import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static String? _fcmToken;

  // Notification channel details
  static const String channelKey = 'basic_channel';
  static const String channelName = 'Basic Notifications';
  static const String channelDescription =
      'Notification channel for basic app notifications';
  static const String channelGroupKey = 'basic_channel_group';
  static const String channelGroupName = 'Basic Group';

  /// Initialize the push notification service
  static Future<void> initialize() async {
    try {
      // Initialize Awesome Notifications
      await _initializeAwesomeNotifications();

      // Initialize Firebase Messaging
      await _initializeFirebaseMessaging();

      // Request permissions
      await _requestPermissions();

      // Subscribe to topic 'pn'
      await _subscribeToTopic();

      // Setup message handlers
      _setupMessageHandlers();

      // Get FCM token
      await _getFCMToken();

      if (kDebugMode) {
        print('✅ Push Notification Service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Push Notification Service: $e');
      }
    }
  }

  /// Initialize Awesome Notifications
  static Future<void> _initializeAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/ic_notification', // App icon for notifications
      [
        NotificationChannel(
          channelKey: channelKey,
          channelName: channelName,
          channelDescription: channelDescription,
          channelGroupKey: channelGroupKey,
          defaultColor: const Color(0xFF6366F1),
          ledColor: const Color(0xFF6366F1),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: channelGroupKey,
          channelGroupName: channelGroupName,
        ),
      ],
      debug: kDebugMode,
    );
  }

  /// Initialize Firebase Messaging
  static Future<void> _initializeFirebaseMessaging() async {
    // Configure Firebase Messaging settings
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    // Request Firebase Messaging permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Request Awesome Notifications permissions
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    if (kDebugMode) {
      print(
        'Firebase Messaging permission status: ${settings.authorizationStatus}',
      );
      print('Awesome Notifications permission: $isAllowed');
    }
  }

  /// Subscribe to the 'pn' topic
  static Future<void> _subscribeToTopic() async {
    try {
      await _firebaseMessaging.subscribeToTopic('pn');
      if (kDebugMode) {
        print('✅ Successfully subscribed to topic: pn');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error subscribing to topic: $e');
      }
    }
  }

  /// Setup message handlers for different app states
  static void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle notification taps when app is terminated
    _handleTerminatedAppMessage();
  }

  /// Handle messages when app is in foreground
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📱 Received foreground message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    await _showLocalNotification(message);
  }

  /// Handle notification taps when app is in background
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📱 Opened app from background notification: ${message.messageId}');
    }

    _handleNotificationTap(message);
  }

  /// Handle notification taps when app was terminated
  static Future<void> _handleTerminatedAppMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      if (kDebugMode) {
        print(
          '📱 Opened app from terminated state: ${initialMessage.messageId}',
        );
      }

      _handleNotificationTap(initialMessage);
    }
  }

  /// Show local notification using Awesome Notifications
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      String title = message.notification?.title ?? 'MyEdu Notification';
      String body = message.notification?.body ?? 'You have a new notification';

      // Extract custom data
      Map<String, String?> customData = {};
      message.data.forEach((key, value) {
        customData[key] = value.toString();
      });

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: channelKey,
          title: title,
          body: body,
          icon: 'resource://drawable/ic_notification', // Add small icon here
          bigPicture: message.notification?.android?.imageUrl,
          largeIcon: message.notification?.android?.imageUrl,
          notificationLayout:
              message.notification?.android?.imageUrl != null
                  ? NotificationLayout.BigPicture
                  : NotificationLayout.Default,
          category: NotificationCategory.Message,
          wakeUpScreen: true,
          fullScreenIntent: false,
          criticalAlert: true,
          color: const Color(0xFF6366F1),
          backgroundColor: const Color(0xFF6366F1),
          payload: customData,
          customSound: 'resource://raw/notification_sound',
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'OPEN',
            label: 'Open',
            actionType: ActionType.Default,
            color: const Color(0xFF6366F1),
          ),
          NotificationActionButton(
            key: 'DISMISS',
            label: 'Dismiss',
            actionType: ActionType.DismissAction,
            isDangerousOption: true,
          ),
        ],
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error showing local notification: $e');
      }
    }
  }

  /// Handle notification tap actions
  static void _handleNotificationTap(RemoteMessage message) {
    // You can navigate to specific screens based on notification data
    if (message.data.isNotEmpty) {
      String? screen = message.data['screen'];
      String? route = message.data['route'];

      if (screen != null || route != null) {
        // Navigate to specific screen based on data
        if (route != null) {
          Get.toNamed(route);
        } else {
          _navigateBasedOnScreen(screen!);
        }
      }
    }
  }

  /// Navigate to specific screen based on notification data
  static void _navigateBasedOnScreen(String screen) {
    switch (screen.toLowerCase()) {
      case 'notices':
        Get.toNamed('/notices');
        break;
      case 'dashboard':
        Get.toNamed('/dashboard');
        break;
      case 'fees':
        // Navigate to academic fees if you have that route
        break;
      default:
        // Default to dashboard
        Get.toNamed('/dashboard');
        break;
    }
  }

  /// Get FCM token
  static Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (kDebugMode && _fcmToken != null) {
        print('📱 FCM Token: $_fcmToken');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting FCM token: $e');
      }
    }
  }

  /// Get current FCM token
  static String? get fcmToken => _fcmToken;

  /// Refresh FCM token
  static Future<String?> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = await _firebaseMessaging.getToken();
      return _fcmToken;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing FCM token: $e');
      }
      return null;
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('pn');
      if (kDebugMode) {
        print('✅ Successfully unsubscribed from topic: pn');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error unsubscribing from topic: $e');
      }
    }
  }

  /// Setup notification action listeners
  static void setupNotificationActionListeners() {
    // Listen for notification actions
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  /// Handle notification actions
  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    if (kDebugMode) {
      print(
        '🔘 Notification action received: ${receivedAction.buttonKeyPressed}',
      );
    }

    // Handle different action buttons
    switch (receivedAction.buttonKeyPressed) {
      case 'OPEN':
        // Navigate based on payload data
        if (receivedAction.payload != null) {
          String? screen = receivedAction.payload!['screen'];
          String? route = receivedAction.payload!['route'];

          if (route != null) {
            Get.toNamed(route);
          } else if (screen != null) {
            _navigateBasedOnScreen(screen);
          } else {
            Get.toNamed('/dashboard');
          }
        } else {
          Get.toNamed('/dashboard');
        }
        break;
      case 'DISMISS':
        // Do nothing, notification is automatically dismissed
        break;
    }
  }

  /// Handle notification creation
  static Future<void> _onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    if (kDebugMode) {
      print('📝 Notification created: ${receivedNotification.id}');
    }
  }

  /// Handle notification display
  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    if (kDebugMode) {
      print('👀 Notification displayed: ${receivedNotification.id}');
    }
  }

  /// Handle notification dismiss
  static Future<void> _onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    if (kDebugMode) {
      print('🗑️ Notification dismissed: ${receivedAction.id}');
    }
  }

  /// Test notification (for debugging)
  static Future<void> sendTestNotification() async {
    if (kDebugMode) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: channelKey,
          title: 'Test Notification',
          body: 'This is a test notification from MyEdu',
          icon: 'resource://drawable/ic_notification', // Add small icon here
          category: NotificationCategory.Message,
          wakeUpScreen: true,
          color: const Color(0xFF6366F1),
        ),
      );
    }
  }

  /// Dispose resources
  static void dispose() {
    // Clean up resources if needed
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📱 Background message received: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
  }

  // You can process the background message here if needed
  // Note: You cannot show UI from background handler
}

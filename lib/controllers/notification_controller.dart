import 'package:get/get.dart';
import 'package:myedu/services/push_notification_service.dart';

class NotificationController extends GetxController {
  final RxBool _isNotificationEnabled = true.obs;
  final RxString _fcmToken = ''.obs;
  final RxInt _notificationCount = 0.obs;
  final RxList<Map<String, dynamic>> _notifications =
      <Map<String, dynamic>>[].obs;

  bool get isNotificationEnabled => _isNotificationEnabled.value;
  String get fcmToken => _fcmToken.value;
  int get notificationCount => _notificationCount.value;
  List<Map<String, dynamic>> get notifications => _notifications.toList();

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await PushNotificationService.initialize();

      PushNotificationService.setupNotificationActionListeners();

      String? token = PushNotificationService.fcmToken;
      if (token != null) {
        _fcmToken.value = token;
      }

      print('✅ Notification Controller initialized successfully');
    } catch (e) {
      print('❌ Error initializing Notification Controller: $e');
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    _isNotificationEnabled.value = enabled;

    if (enabled) {
      await PushNotificationService.initialize();
    } else {
      await PushNotificationService.unsubscribeFromTopic();
    }
  }

  Future<void> refreshFCMToken() async {
    String? newToken = await PushNotificationService.refreshToken();
    if (newToken != null) {
      _fcmToken.value = newToken;
    }
  }

  void addNotification({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    });

    _notificationCount.value = _notifications.length;
  }

  void markAsRead(int id) {
    int index = _notifications.indexWhere(
      (notification) => notification['id'] == id,
    );
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      _notifications.refresh();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    _notifications.refresh();
  }

  void clearAllNotifications() {
    _notifications.clear();
    _notificationCount.value = 0;
  }

  void clearNotification(int id) {
    _notifications.removeWhere((notification) => notification['id'] == id);
    _notificationCount.value = _notifications.length;
  }

  int get unreadCount {
    return _notifications
        .where((notification) => !notification['isRead'])
        .length;
  }

  Future<void> sendTestNotification() async {
    await PushNotificationService.sendTestNotification();

    addNotification(
      title: 'Test Notification',
      body: 'This is a test notification from MyEdu',
      data: {'screen': 'dashboard'},
    );
  }

  @override
  void onClose() {
    PushNotificationService.dispose();
    super.onClose();
  }
}

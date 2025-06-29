import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';

class NotificationsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  void fetchNotifications() async {
    try {
      isLoading.value = true;
      final QuerySnapshot snapshot =
          await _firestore
              .collection('notifications')
              .orderBy('timestamp', descending: true)
              .get();

      final List<NotificationModel> fetchedNotifications =
          snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();

      notifications.assignAll(fetchedNotifications);
      _updateUnreadCount();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch notifications: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });

      // Update local state
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark notification as read: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void markAllAsRead() async {
    try {
      final batch = _firestore.batch();
      for (final notification in notifications.where((n) => !n.isRead)) {
        batch.update(
          _firestore.collection('notifications').doc(notification.id),
          {'isRead': true},
        );
      }
      await batch.commit();

      // Update local state
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = notifications[i].copyWith(isRead: true);
        }
      }
      _updateUnreadCount();

      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark all notifications as read: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();

      notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();

      Get.snackbar(
        'Success',
        'Notification deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete notification: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  void refreshNotifications() {
    fetchNotifications();
  }

  List<NotificationModel> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get readNotifications =>
      notifications.where((n) => n.isRead).toList();
}

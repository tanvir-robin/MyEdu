import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myedu/controllers/notification_controller.dart';

class NotificationHistoryView extends StatelessWidget {
  const NotificationHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController notificationController =
        Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed:
                () => _showClearAllDialog(context, notificationController),
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All',
          ),
          IconButton(
            onPressed: () => notificationController.markAllAsRead(),
            icon: const Icon(Icons.mark_email_read),
            tooltip: 'Mark All as Read',
          ),
        ],
      ),
      body: Obx(() {
        if (notificationController.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh logic if needed
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notificationController.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationController.notifications[index];
              return _buildNotificationCard(
                context,
                notification,
                notificationController,
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => notificationController.sendTestNotification(),
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.notification_add, color: Colors.white),
        tooltip: 'Send Test Notification',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 64,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications yet',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see your notifications here when you receive them',
            style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    Map<String, dynamic> notification,
    NotificationController controller,
  ) {
    final bool isRead = notification['isRead'] ?? false;
    final DateTime timestamp = DateTime.parse(notification['timestamp']);
    final String timeAgo = _getTimeAgo(timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isRead
                  ? Colors.transparent
                  : const Color(0xFF6366F1).withOpacity(0.3),
          width: isRead ? 0 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          controller.markAsRead(notification['id']);
          _handleNotificationTap(notification);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _getNotificationIcon(notification['data']),
                  color: const Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] ?? 'Notification',
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.bold,
                              color: isRead ? Colors.grey[600] : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6366F1),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['body'] ?? '',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed:
                              () => _showDeleteDialog(
                                context,
                                notification['id'],
                                controller,
                              ),
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.grey[500],
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(Map<String, dynamic>? data) {
    if (data == null) return Icons.notifications;

    String screen = data['screen']?.toString().toLowerCase() ?? '';
    switch (screen) {
      case 'notices':
        return Icons.campaign;
      case 'fees':
        return Icons.payment;
      case 'grades':
        return Icons.grade;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.notifications;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final data = notification['data'] as Map<String, dynamic>?;
    if (data != null) {
      String? screen = data['screen']?.toString();
      String? route = data['route']?.toString();

      if (route != null) {
        Get.toNamed(route);
      } else if (screen != null) {
        _navigateBasedOnScreen(screen);
      }
    }
  }

  void _navigateBasedOnScreen(String screen) {
    switch (screen.toLowerCase()) {
      case 'notices':
        Get.toNamed('/notices');
        break;
      case 'dashboard':
        Get.toNamed('/dashboard');
        break;
      default:
        Get.toNamed('/dashboard');
        break;
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    int notificationId,
    NotificationController controller,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Notification'),
            content: const Text(
              'Are you sure you want to delete this notification?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  controller.clearNotification(notificationId);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    NotificationController controller,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Notifications'),
            content: const Text(
              'Are you sure you want to clear all notifications?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  controller.clearAllNotifications();
                  Navigator.of(context).pop();
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/notifications_controller.dart';
import '../models/notification_model.dart';

class AllNotificationsScreen extends StatelessWidget {
  const AllNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationsController = Get.put(NotificationsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Obx(
            () =>
                notificationsController.unreadCount.value > 0
                    ? IconButton(
                      onPressed: () => notificationsController.markAllAsRead(),
                      icon: const Icon(Icons.done_all),
                      tooltip: 'Mark all as read',
                    )
                    : const SizedBox.shrink(),
          ),
          IconButton(
            onPressed: () => notificationsController.refreshNotifications(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6366F1), Color(0xFFF8FAFC)],
            stops: [0.0, 0.3],
          ),
        ),
        child: Obx(() {
          if (notificationsController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            );
          }

          if (notificationsController.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              notificationsController.refreshNotifications();
            },
            child: Column(
              children: [
                // Stats header
                _buildStatsHeader(notificationsController),
                // Notifications list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notificationsController.notifications.length,
                    itemBuilder: (context, index) {
                      final notification =
                          notificationsController.notifications[index];
                      return _buildNotificationTile(
                        context,
                        notification,
                        notificationsController,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see notifications here when you receive them',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(NotificationsController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total',
              controller.notifications.length.toString(),
              Icons.notifications,
              const Color(0xFF6366F1),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          Expanded(
            child: _buildStatItem(
              'Unread',
              controller.unreadCount.value.toString(),
              Icons.mark_email_unread,
              Colors.orange,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          Expanded(
            child: _buildStatItem(
              'Read',
              controller.readNotifications.length.toString(),
              Icons.mark_email_read,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationModel notification,
    NotificationsController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border:
            notification.isRead
                ? Border.all(color: Colors.grey.shade200)
                : Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!notification.isRead) {
              controller.markAsRead(notification.id);
            }
            _showNotificationDetails(context, notification);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon/avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getNotificationTypeColor(
                      notification.type,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getNotificationTypeIcon(notification.type),
                    color: _getNotificationTypeColor(notification.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    notification.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
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
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeago.format(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Spacer(),
                          _buildNotificationTypeChip(notification.type),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'mark_read':
                        controller.markAsRead(notification.id);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(
                          context,
                          notification,
                          controller,
                        );
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        if (!notification.isRead)
                          const PopupMenuItem(
                            value: 'mark_read',
                            child: Row(
                              children: [
                                Icon(Icons.mark_email_read, size: 18),
                                SizedBox(width: 8),
                                Text('Mark as read'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getNotificationTypeColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getNotificationTypeColor(type),
        ),
      ),
    );
  }

  IconData _getNotificationTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'academic':
        return Icons.school;
      case 'fee':
        return Icons.payment;
      case 'exam':
        return Icons.quiz;
      case 'event':
        return Icons.event;
      case 'announcement':
        return Icons.campaign;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'academic':
        return Colors.blue;
      case 'fee':
        return Colors.green;
      case 'exam':
        return Colors.orange;
      case 'event':
        return Colors.purple;
      case 'announcement':
        return Colors.red;
      case 'system':
        return Colors.grey;
      default:
        return const Color(0xFF6366F1);
    }
  }

  void _showNotificationDetails(
    BuildContext context,
    NotificationModel notification,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.3,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getNotificationTypeColor(
                                notification.type,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getNotificationTypeIcon(notification.type),
                              color: _getNotificationTypeColor(
                                notification.type,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  timeago.format(notification.createdAt),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildNotificationTypeChip(notification.type),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Text(
                            notification.message,
                            style: const TextStyle(fontSize: 16, height: 1.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    NotificationModel notification,
    NotificationsController controller,
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
                  Navigator.of(context).pop();
                  controller.deleteNotification(notification.id);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

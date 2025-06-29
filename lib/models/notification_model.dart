import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? imageUrl;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      type: data['type'] as String? ?? 'general',
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      data: data['data'] as Map<String, dynamic>?,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      type: json['type'] as String? ?? 'general',
      isRead: json['isRead'] as bool? ?? false,
      createdAt:
          json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(
                json['createdAt'] as String? ??
                    DateTime.now().toIso8601String(),
              ),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt,
      'data': data,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? imageUrl,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }
}

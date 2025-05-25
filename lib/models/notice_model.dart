import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel {
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoticeModel({
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

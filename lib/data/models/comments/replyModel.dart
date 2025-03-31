// lib/models/reply_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final String articleId;   // ID of the parent article
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime? timestamp;

  const Reply({
    required this.articleId,
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    this.timestamp,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      articleId: json['articleId'] ?? '', // Assuming you have this field
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] == null
          ? null
          : (json['timestamp'] as DateTime),
    );
  }
}

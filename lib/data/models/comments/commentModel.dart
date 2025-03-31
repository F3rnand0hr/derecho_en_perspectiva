class Comment {
  final String id; // The doc ID of the comment
  final String userId;
  final String userName;
  final String text;
  final DateTime? timestamp;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      text: json['text'] ?? '',
      // Firestore timestamps come as a `Timestamp` object, so convert to DateTime
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] as DateTime?) // if you're already using toDate() 
          : null,
    );
  }
}

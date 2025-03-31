// lib/repositories/thread_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:derecho_en_perspectiva/data/models/comments/replyModel.dart';

class ThreadRepository {
  /// Returns a stream of all replies within a subcollection
  /// (for example, "articulos/{articleId}/comments/{commentId}/replies").
  Stream<List<Reply>> getRepliesStream(CollectionReference<Map<String, dynamic>> repliesCollection) {
    return repliesCollection
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((querySnap) {
      return querySnap.docs.map((docSnap) {
        final data = docSnap.data();
        final mergedData = {
          'id': docSnap.id,
          ...data,
        };

        // Convert Firestore Timestamp -> DateTime
        final ts = mergedData['timestamp'] as Timestamp?;
        if (ts != null) {
          mergedData['timestamp'] = ts.toDate();
        }

        return Reply.fromJson(mergedData);
      }).toList();
    });
  }

  /// Add a new reply to the given subcollection
  Future<void> addReply({
    required CollectionReference<Map<String, dynamic>> repliesCollection,
    required String userId,
    required String userName,
    required String text,
  }) async {
    await repliesCollection.add({
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:derecho_en_perspectiva/data/models/comments/commentModel.dart';


class CommentsRepository {
  final CollectionReference<Map<String, dynamic>> _articlesRef =
      FirebaseFirestore.instance.collection('articulos');



  // ...

  /// Returns a Stream<List<Comment>> for the subcollection of comments.
  /// Sort descending by timestamp, if needed.
  Stream<List<Comment>> getCommentsForArticle(String articleId) {
    return _articlesRef
        .doc(articleId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnap) {
      return querySnap.docs.map((docSnap) {
        // Convert docSnap -> Map -> Comment
        final data = docSnap.data();
        final mergedData = {
          'id': docSnap.id,
          ...data,
        };

        // Handle Firestore Timestamp -> DateTime if you want
        final timestamp = mergedData['timestamp'] as Timestamp?;
        if (timestamp != null) {
          mergedData['timestamp'] = timestamp.toDate();
        }

        return Comment.fromJson(mergedData);
      }).toList();
    });
  }

  /// Optionally, a method to create a new comment
  Future<void> addComment({
    required String articleId,
    required String userId,
    required String userName,
    required String text,
  }) {
    return _articlesRef.doc(articleId).collection('comments').add({
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }


  // Stream<List<Comment>> getRepliesStream({
  //   required CollectionReference<Map<String, dynamic>> repliesCollection,
  // }) {
  //   return repliesCollection
  //       .orderBy('timestamp', descending: false)
  //       .snapshots()
  //       .map((querySnap) {
  //     return querySnap.docs.map((docSnap) {
  //       final data = docSnap.data();
  //       return Comment.fromJson({
  //         'id': docSnap.id,
  //         ...data,
  //       });
  //     }).toList();
  //   });
  // }


  // Future<void> postReply({
  //   required CollectionReference<Map<String, dynamic>> repliesCollection,
  //   required String userId,
  //   required String userName,
  //   required String text,
  // }) {
  //   return repliesCollection.add({
  //     'userId': userId,
  //     'userName': userName,
  //     'text': text,
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });
  // }
  // // ...
}




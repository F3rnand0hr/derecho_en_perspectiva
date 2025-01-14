import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleService {
  final FirebaseFirestore _firestore;

  ArticleService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 2) Save article (create or update)
  Future<void> saveArticle({
    required String articleId,
    required String title,
    required String description,
    required String content,
    required String imageURL,
  }) async {
    final docRef = _firestore.collection('articles').doc(articleId);
    await docRef.set({
      'title': title,
      'description': description,
      'content': content,
      'imageURL': imageURL,
      'likedCount': 0,
    }, SetOptions(merge: true));
  }

  // 3) Post comment
  Future<void> postComment({
    required String articleId,
    required String userId,
    required String userName,
    required String text,
  }) async {
    final commentsRef = _firestore
        .collection('articles')
        .doc(articleId)
        .collection('comments');
    await commentsRef.add({
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Post reply (similar to posting a comment, but in 'replies' subcollection)
  Future<void> postReply({
    required String articleId,
    required String commentId,
    required String userId,
    required String userName,
    required String text,
  }) async {
    final repliesRef = _firestore
        .collection('articles')
        .doc(articleId)
        .collection('comments')
        .doc(commentId)
        .collection('replies');

    await repliesRef.add({
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 6) Increment like count
  Future<void> incrementLikeCount(String articleId) async {
    final docRef = _firestore.collection('articles').doc(articleId);
    await docRef.update({
      'likedCount': FieldValue.increment(1),
    });
  }

  // 7) The "share" functionality is usually handled in the UI,
  //    because it involves calling Share.share(...) from share_plus.
  //    However, you *could* store "share" metadata in Firestore if you like.
}

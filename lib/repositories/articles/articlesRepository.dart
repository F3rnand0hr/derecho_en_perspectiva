// lib/repositories/article_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:derecho_en_perspectiva/data/models/articleModel.dart';

class ArticleRepository {
  final CollectionReference<Map<String, dynamic>> _articlesRef =
      FirebaseFirestore.instance.collection('articulos');

  // This returns a *stream* of Article objects (or null if doc doesn't exist)
  Stream<Article?> getArticleStream(String articleId) {
    return _articlesRef.doc(articleId).snapshots().map((docSnap) {
      if (!docSnap.exists) {
        return null; // or throw an error, or return a default Article
      }

      final data = docSnap.data();
      if (data == null) {
        return null;
      }

      // Merge doc ID with the data so "fromJson" has an 'id'
      final mergedData = {
        'id': docSnap.id,
        ...data, 
      };

      return Article.fromJson(mergedData);
    });
  }

  // Like an article (add userId to 'liked' list)
  Future<void> likeArticle(String articleId, String userId) {
    return _articlesRef.doc(articleId).update({
      'liked': FieldValue.arrayUnion([userId]),
    });
  }

  // Unlike an article (remove userId from 'liked' list)
  Future<void> unlikeArticle(String articleId, String userId) {
    return _articlesRef.doc(articleId).update({
      'liked': FieldValue.arrayRemove([userId]),
    });
  }

  // Optional: read doc once to check if it exists
  Future<bool> articleExists(String articleId) async {
    final snap = await _articlesRef.doc(articleId).get();
    return snap.exists;
  }
}

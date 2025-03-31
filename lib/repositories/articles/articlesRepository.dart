// lib/repositories/article_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:derecho_en_perspectiva/data/models/articleModel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  StreamBuilder<QuerySnapshot> getArticlesStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('articulos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final articles = snapshot.data!.docs;

          if (articles.isEmpty) {
            return const Center(
              child: Text('No articles found.'),
            );
          }

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final doc = articles[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Untitled';
              final description = data['description'] ?? '';
              final imageURL = data['imageURL'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: imageURL.isNotEmpty
                      ? Image.network(
                          imageURL,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.article),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    context.push('/article/${doc.id}');
                  },
                ),
              );
            },
          );
      },
    );
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

// lib/models/article_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String imageURL;
  final List<String> liked;

  const Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageURL,
    required this.liked,
  });

  /// Create an Article from a generic JSON/Map. 
  /// This means you can feed data from Firestore,
  /// a REST API, or any other external JSON source.
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      imageURL: json['imageURL'] ?? '',
      liked: json['liked'] == null
          ? <String>[]
          : List<String>.from(json['liked']),
    );
  }
}

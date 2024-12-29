import 'package:derecho_en_perspectiva/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:derecho_en_perspectiva/models/articles.dart'; // Import the articles model

class ArticlePage extends StatelessWidget {
  final Article article;

  // Accept the article data in the constructor
  const ArticlePage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(article.imageUrl), // Display the article image
            SizedBox(height: 16),
            Text(
              article.title,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              article.description,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),
            // Display the content of the article
            Text(
              article.content,
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

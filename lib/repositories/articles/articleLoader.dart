import 'package:flutter/material.dart';
import 'package:derecho_en_perspectiva/data/models/articleModel.dart';
import 'package:derecho_en_perspectiva/repositories/articles/articlesRepository.dart';

class ArticleLoader extends StatelessWidget {
  final String articleId;
  final Widget Function(BuildContext context, Article article) builder;

  const ArticleLoader({
    super.key,
    required this.articleId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final articleRepository = ArticleRepository();
    return StreamBuilder<Article?>(
      stream: articleRepository.getArticleStream(articleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Article not found'));
        }
        return builder(context, snapshot.data!);
      },
    );
  }
}

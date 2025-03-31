import 'package:derecho_en_perspectiva/repositories/articles/articlesRepository.dart';
import 'package:derecho_en_perspectiva/repositories/comments/commentsRepo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({Key? key}) : super(key: key);

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  final _articleRepository = ArticleRepository();
  final _commentsRepository = CommentsRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
      ),
      body: _articleRepository.getArticlesStream(),
    );
  }
}

import 'package:derecho_en_perspectiva/data/models/articleModel.dart';
import 'package:derecho_en_perspectiva/data/models/comments/commentModel.dart';
import 'package:derecho_en_perspectiva/repositories/articles/articlesRepository.dart';
import 'package:derecho_en_perspectiva/repositories/comments/commentsRepo.dart';
import 'package:derecho_en_perspectiva/services/newCommentInput.dart';
import 'package:derecho_en_perspectiva/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:derecho_en_perspectiva/pages/widgets/threadWidget.dart';
import 'package:derecho_en_perspectiva/pages/widgets/appDrawer.dart';
import 'package:derecho_en_perspectiva/cubits/authCubit.dart';

class ArticlePage extends StatefulWidget {
  final String articleId;
  const ArticlePage({super.key, required this.articleId});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final _articleRepository = ArticleRepository();
  final _commentsRepository = CommentsRepository();

  bool _commentsVisible = false;
  bool _isPosting = false;

  Future<void> _handleCommentSubmit(String text) async {
    setState(() => _isPosting = true);
    try {
      final user = context.read<AuthCubit>().state;
      final userId = user?.uid;
      final userName = user?.displayName ?? 'Anonymous';

      if (userId == null) {
        // handle not logged in scenario, e.g. show a dialog
        return;
      }

      // Add the new top-level comment
      await _commentsRepository.addComment(
        articleId: widget.articleId,
        userId: userId,
        userName: userName,
        text: text,
      );
    } catch (e) {
      print('Error posting comment: $e');
    } finally {
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Article?>(
      stream: _articleRepository.getArticleStream(widget.articleId),
      builder: (context, snapshot) {
        final articleUrl =
            'https://derecho-en-perspectiva.web.app/#/article/${widget.articleId}';

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Article Not Found')),
            body: const Center(child: Text('Article not found')),
          );
        }

        final article = snapshot.data!;
        final title = article.title;
        final description = article.description;
        final content = article.content;
        final imageURL = article.imageURL;
        final liked = article.liked;

        return Scaffold(
          appBar: AppBar(
            title: Text(title.isNotEmpty ? title : 'Article Detail'),
          ),
          drawer: appDrawer(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageURL.isNotEmpty)
                  // Use Image.network if the image is hosted online
                  Image.network(imageURL, fit: BoxFit.cover),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        liked.contains(context.read<AuthCubit>().state?.uid)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: liked.contains(context.read<AuthCubit>().state?.uid)
                            ? Colors.red
                            : AppColors.spaceCadet,
                      ),
                      onPressed: context.read<AuthCubit>().state == null
                          ? null
                          : () async {
                              if (liked.contains(context.read<AuthCubit>().state?.uid)) {
                                await _articleRepository.unlikeArticle(
                                  widget.articleId,
                                  context.read<AuthCubit>().state!.uid,
                                );
                              } else {
                                await _articleRepository.likeArticle(
                                  widget.articleId,
                                  context.read<AuthCubit>().state!.uid,
                                );
                              }
                            },
                    ),
                    Text('${liked.length}'),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _commentsVisible ? Icons.chat_bubble : Icons.chat_bubble_outline,
                        color: AppColors.spaceCadet,
                      ),
                      onPressed: () {
                        setState(() {
                          _commentsVisible = !_commentsVisible;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: AppColors.spaceCadet),
                      onPressed: () {
                        Share.share(
                          'Check out this article:\n'
                          '$title\n\n'
                          '$description\n'
                          'Read more: $articleUrl',
                        );
                      },
                    ),
                  ],
                ),
                if (_commentsVisible) ...[
                  NewCommentInput(
                    onSubmit: _handleCommentSubmit,
                    isPosting: _isPosting,
                  ),
                  const SizedBox(height: 16),
                  // Stream top-level comments using the CommentsRepository
                  StreamBuilder<List<Comment>>(
                    stream: _commentsRepository.getCommentsForArticle(widget.articleId),
                    builder: (context, commentSnapshot) {
                      if (commentSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!commentSnapshot.hasData || commentSnapshot.data!.isEmpty) {
                        return const Text('No comments yet. Be the first to comment!');
                      }
                      final comments = commentSnapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ThreadWidget(
                            articleId: widget.articleId,
                            docId: comment.id,
                            userId: comment.userId,
                            userName: comment.userName,
                            text: comment.text,
                            timestamp: comment.timestamp != null
                                ? Timestamp.fromDate(comment.timestamp!)
                                : null,
                            // Pass the replies subcollection for this comment
                            repliesCollection: FirebaseFirestore.instance
                                .collection('articulos')
                                .doc(widget.articleId)
                                .collection('comments')
                                .doc(comment.id)
                                .collection('replies'),
                          );
                        },
                      );
                    },
                  ),
                ],
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 16),
                Text(content, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }
}

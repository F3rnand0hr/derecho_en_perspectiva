import 'package:derecho_en_perspectiva/data/models/comments/commentModel.dart';
import 'package:derecho_en_perspectiva/repositories/articles/articleLike.dart';
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
import 'package:derecho_en_perspectiva/repositories/articles/articleLoader.dart';

class ArticlePage extends StatefulWidget {
  final String articleId;
  const ArticlePage({super.key, required this.articleId});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
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
    return ArticleLoader(
      articleId: widget.articleId,
      builder: (context, article) {
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
                    LikeButton(articleId: widget.articleId),
                    Text('${liked.length}'),
                    const SizedBox(width: 8),
                    commentsIcon(
                      _commentsVisible,
                      () {
                        setState(() {
                          _commentsVisible = !_commentsVisible;
                        });
                      },
                    ),
                    shareButton(title, description, widget.articleId),
                  ],
                ),
                commentList(commentsVisible: _commentsVisible, onSubmit: _handleCommentSubmit, isPosting: _isPosting, commentStream: _commentsRepository.getCommentsForArticle(widget.articleId), articleId: widget.articleId),
                const SizedBox(height: 8),
                Text(description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
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


Widget commentsIcon(bool _commentsVisible, VoidCallback onToggleComments) {
  return IconButton(
    icon: Icon(
      _commentsVisible ? Icons.chat_bubble : Icons.chat_bubble_outline,
      color: AppColors.spaceCadet,
    ),
    onPressed: onToggleComments,
  );
}

Widget shareButton(String title, String description, String articleId) {
  final articleUrl =
            'https://derecho-en-perspectiva.web.app/#/article/${articleId}';

  return IconButton(
    icon:
        const Icon(Icons.share, color: AppColors.spaceCadet),
    onPressed: () {
      Share.share(
        'Check out this article:\n'
        '$title\n\n'
        '$description\n'
        'Read more: $articleUrl',
      );
    },
  );
}

Widget commentList({
  required bool commentsVisible,
  required Future<void> Function(String) onSubmit,
  required bool isPosting,
  required Stream<List<Comment>> commentStream,
  required String articleId,
}) {
  if (!commentsVisible) return const SizedBox.shrink();

  return Column(
    children: [
      NewCommentInput(
        onSubmit: onSubmit,
        isPosting: isPosting,
      ),
      const SizedBox(height: 16),
      StreamBuilder<List<Comment>>(
        stream: commentStream,
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
                articleId: articleId,
                docId: comment.id,
                userId: comment.userId,
                userName: comment.userName,
                text: comment.text,
                timestamp: comment.timestamp != null
                    ? Timestamp.fromDate(comment.timestamp!)
                    : null,
                repliesCollection: FirebaseFirestore.instance
                    .collection('articulos')
                    .doc(articleId)
                    .collection('comments')
                    .doc(comment.id)
                    .collection('replies'),
              );
            },
          );
        },
      ),
    ],
  );
}

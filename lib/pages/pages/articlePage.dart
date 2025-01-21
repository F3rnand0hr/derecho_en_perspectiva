import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:derecho_en_perspectiva/pages/widgets/threadWidget.dart';
import 'package:derecho_en_perspectiva/pages/widgets/comment_widget.dart';
import 'package:derecho_en_perspectiva/pages/widgets/appDrawer.dart';
import 'package:derecho_en_perspectiva/cubits/authCubit.dart';

class ArticlePage extends StatefulWidget {
  final String articleId;

  const ArticlePage({Key? key, required this.articleId}) : super(key: key);

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  bool _commentsVisible = false; 

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state; // Get current user
    final userId = user?.uid; // Use user.uid for unique user identifier

    return Scaffold(
      drawer: appDrawer(context),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('articulos')
            .doc(widget.articleId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Loading...'), // Placeholder title
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.data!.exists) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Article Not Found'),
              ),
              body: const Center(child: Text('Article not found')),
            );
          }

          final articleData = snapshot.data!.data() as Map<String, dynamic>;
          final title = articleData['title'] ?? '';
          final description = articleData['description'] ?? '';
          final content = articleData['content'] ?? '';
          final imageURL = articleData['imageURL'] ?? '';
          final liked = List<String>.from(articleData['liked'] ?? []);

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
                  imageURL.isNotEmpty
                      ? Image.asset(imageURL, fit: BoxFit.cover)
                      : const SizedBox.shrink(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          liked.contains(userId)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              liked.contains(userId) ? Colors.red : Colors.grey,
                        ),
                        onPressed: userId == null
                            ? null
                            : () async {
                                  // Remove user ID from the liked array
                                if (liked.contains(userId)) {
                                  // Remove user ID from the liked array
                                  await FirebaseFirestore.instance
                                      .collection('articulos')
                                      .doc(widget.articleId)
                                      .update({
                                    'liked': FieldValue.arrayRemove([userId]),
                                  });
                                } 
                                // Add user ID to the liked array
                                else {
                                  await FirebaseFirestore.instance
                                      .collection('articulos')
                                      .doc(widget.articleId)
                                      .update({
                                    'liked': FieldValue.arrayUnion([userId]),
                                  });
                                }
                              },
                      ),
                      Text('${liked.length}'),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _commentsVisible
                              ? Icons.chat_bubble
                              : Icons.chat_bubble_outline,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _commentsVisible = !_commentsVisible; // Toggle visibility
                          });
                        },
                      ),
                      IconButton(
                      icon: const Icon(Icons.share, color: Colors.grey),
                      onPressed: () async {
                        final articleSnap = await FirebaseFirestore.instance
                            .collection('articulos')
                            .doc(widget.articleId)
                            .get();

                        if (articleSnap.exists) {
                          final data = articleSnap.data() as Map<String, dynamic>;
                          final title = data['title'] ?? '';
                          final description = data['description'] ?? '';
                          Share.share('Check out this article:\n$title\n\n$description');
                        }
                      },
                    ),
                    ],
                  ),
                  if (_commentsVisible)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _NewCommentInput(articleId: widget.articleId),
                        const SizedBox(height: 16),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('articulos')
                              .doc(widget.articleId)
                              .collection('comments')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final commentDocs = snapshot.data!.docs;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: commentDocs.length,
                              itemBuilder: (context, index) {
                                final doc = commentDocs[index];
                                final data =
                                    doc.data() as Map<String, dynamic>;
                                final repliesCollection = FirebaseFirestore
                                    .instance
                                    .collection('articulos')
                                    .doc(widget.articleId)
                                    .collection('comments')
                                    .doc(doc.id)
                                    .collection('replies');
                                return ThreadWidget(
                                  articleId: widget.articleId,
                                  docId: doc.id,
                                  userId: data['userId'] ?? '',
                                  userName: data['userName'] ?? '',
                                  text: data['text'] ?? '',
                                  timestamp: data['timestamp'] as Timestamp?,
                                  repliesCollection: repliesCollection,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class _NewCommentInput extends StatefulWidget {
  final String articleId;

  const _NewCommentInput({Key? key, required this.articleId}) : super(key: key);

  @override
  State<_NewCommentInput> createState() => _NewCommentInputState();
}

class _NewCommentInputState extends State<_NewCommentInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state; 
    final userId = user?.uid;
    final userName = user?.displayName;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Write a comment...',
            ),
          ),
        ),
        IconButton(
          icon: _isPosting
              ? const CircularProgressIndicator()
              : const Icon(Icons.send),
          onPressed: _isPosting || userId == null
              ? null
              : () async {
                  if (_controller.text.trim().isEmpty) return;
                  setState(() => _isPosting = true);

                  await FirebaseFirestore.instance
                      .collection('articulos')
                      .doc(widget.articleId)
                      .collection('comments')
                      .add({
                    'userId': userId,
                    'userName': userName,
                    'text': _controller.text.trim(),
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  _controller.clear();
                  setState(() => _isPosting = false);
                },
        ),
      ],
    );
  }
} 
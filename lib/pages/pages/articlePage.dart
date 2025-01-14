import 'package:derecho_en_perspectiva/pages/widgets/threadWidget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:derecho_en_perspectiva/pages/widgets/comment_widget.dart'; 
import 'package:derecho_en_perspectiva/pages/widgets/appDrawer.dart';

class ArticlePage extends StatefulWidget {
  final String articleId;

  const ArticlePage({Key? key, required this.articleId}) : super(key: key);

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: appDrawer(context),
      appBar: AppBar(
        title: const Text('Article Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('articulos')
            .doc(widget.articleId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.data!.exists) {
            return const Center(child: Text('Article not found'));
          }

          final articleData = snapshot.data!.data() as Map<String, dynamic>;
          final title = articleData['title'] ?? '';
          final description = articleData['description'] ?? '';
          final content = articleData['content'] ?? '';
          final imageURL = articleData['imageURL'] ?? '';
          final likedCount = articleData['likedCount'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageURL.isNotEmpty
                    ? Image.asset(imageURL, fit: BoxFit.cover)
                    : const SizedBox.shrink(),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text('Likes: $likedCount'),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.thumb_up),
                      label: const Text('Like'),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('articulos')
                            .doc(widget.articleId)
                            .update({
                          'likedCount': FieldValue.increment(1),
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
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
                      return const Center(child: CircularProgressIndicator());
                    }

                    final commentDocs = snapshot.data!.docs;
                    // Where you currently map over the commentDocs...
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: commentDocs.length,
                      itemBuilder: (context, index) {
                        final doc = commentDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                    
                        // For top-level comments, the "replies" subcollection is:
                        //   "articulos / {articleId} / comments / {commentId} / replies"
                        final repliesCollection = FirebaseFirestore.instance
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
          onPressed: _isPosting
              ? null
              : () async {
                  if (_controller.text.trim().isEmpty) return;
                  setState(() => _isPosting = true);

                  await FirebaseFirestore.instance
                      .collection('articulos')
                      .doc(widget.articleId)
                      .collection('comments')
                      .add({
                    'userId': 'someUserId', // Replace with actual user ID
                    'userName': 'SomeUser', // Replace with actual user name
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

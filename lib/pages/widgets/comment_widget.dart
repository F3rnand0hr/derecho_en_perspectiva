import 'package:derecho_en_perspectiva/pages/pages/articleListPage.dart';
import 'package:derecho_en_perspectiva/styles/toast.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class CommentWidget extends StatefulWidget {
  final String articleId;
  final String commentId;
  final String userId;
  final String userName;
  final String text;
  final Timestamp? timestamp;

  const CommentWidget({
    Key? key,
    required this.articleId,
    required this.commentId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
  }) : super(key: key);

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool _showReplyField = false; // toggle to show/hide the reply input

  @override
  Widget build(BuildContext context) {
    // Format timestamp
    final date = widget.timestamp?.toDate().toString().substring(0, 16) ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MAIN COMMENT INFO
            Row(
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(widget.text),

            // REPLY BUTTON
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showReplyField = !_showReplyField;
                  });
                },
                child: const Text('Reply'),
              ),
            ),

            // REPLY INPUT (conditionally displayed)
            if (_showReplyField)
              _NewReplyInput(
                articleId: widget.articleId,
                commentId: widget.commentId,
              ),

            // LIST OF REPLIES
            RepliesList(
              articleId: widget.articleId,
              commentId: widget.commentId,
            ),
          ],
        ),
      ),
    );
  }
}

/// A small widget that displays all replies to a given comment in real time.
class RepliesList extends StatelessWidget {
  final String articleId;
  final String commentId;

  const RepliesList({
    Key? key,
    required this.articleId,
    required this.commentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('articulos')
          .doc(articleId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final replyDocs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: replyDocs.length,
          itemBuilder: (context, index) {
            final data = replyDocs[index].data() as Map<String, dynamic>;
            final userName = data['userName'] ?? 'Unknown';
            final text = data['text'] ?? '';
            final timestamp = data['timestamp'] as Timestamp?;
            final dateStr =
                timestamp?.toDate().toString().substring(0, 16) ?? '';

            return Container(
              margin: const EdgeInsets.only(left: 16.0, top: 8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(text),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// A text field to add a new reply to a specific comment.
class _NewReplyInput extends StatefulWidget {
  final String articleId;
  final String commentId;

  const _NewReplyInput({
    Key? key,
    required this.articleId,
    required this.commentId,
  }) : super(key: key);

  @override
  State<_NewReplyInput> createState() => _NewReplyInputState();
}

class _NewReplyInputState extends State<_NewReplyInput> {
  final TextEditingController _replyController = TextEditingController();
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // REPLY TEXT FIELD
        Expanded(
          child: TextField(
            controller: _replyController,
            decoration: const InputDecoration(
              hintText: 'Write a reply...',
            ),
          ),
        ),
        // SEND BUTTON
        IconButton(
          icon: _isPosting
              ? const CircularProgressIndicator()
              : const Icon(Icons.send),
          onPressed: _isPosting
              ? null
              : () async {
                  final text = _replyController.text.trim();
                  if (text.isEmpty) return;

                  setState(() => _isPosting = true);

                  try {
                    await FirebaseFirestore.instance
                        .collection('articulos')
                        .doc(widget.articleId)
                        .collection('comments')
                        .doc(widget.commentId)
                        .collection('replies')
                        .add({
                      'userId': 'someUserId',   // Replace with real user ID
                      'userName': 'SomeUser',   // Replace with real user name
                      'text': text,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    _replyController.clear();
                  } catch (e) {
                    debugPrint('Error posting reply: $e');
                    showToast(message: 'Crea tu cuenta o inicia sesion para escribir un comentario');
                  }

                  setState(() => _isPosting = false);
                },
        ),
      ],
    );
  }
}

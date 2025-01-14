import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThreadWidget extends StatefulWidget {
  final String articleId;   // ID of the parent article
  final String docId;       // Firestore doc ID of this comment/reply
  final String userId;
  final String userName;
  final String text;
  final Timestamp? timestamp;

  // The path to this doc's "replies" subcollection:
  //   e.g. "articulos/{articleId}/comments/{docId}/replies"
  // If this is a reply to a reply, the path might be nested further.
  final CollectionReference<Map<String, dynamic>> repliesCollection;

  const ThreadWidget({
    Key? key,
    required this.articleId,
    required this.docId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
    required this.repliesCollection,
  }) : super(key: key);

  @override
  State<ThreadWidget> createState() => _ThreadWidgetState();
}

class _ThreadWidgetState extends State<ThreadWidget> {
  bool _showReplyField = false;

  @override
  Widget build(BuildContext context) {
    final date = widget.timestamp?.toDate().toString().substring(0, 16) ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MAIN COMMENT (or reply) HEADER
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

            // MAIN COMMENT TEXT
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

            // REPLY INPUT
            if (_showReplyField)
              _ReplyInput(
                repliesCollection: widget.repliesCollection,
              ),

            // LIST OF CHILD REPLIES
            // Build a StreamBuilder to load any docs in this doc's "replies" subcollection
            StreamBuilder<QuerySnapshot>(
              stream: widget.repliesCollection
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final replyDocs = snapshot.data!.docs;

                // For each child doc, we create another ThreadWidget
                // Note that each child doc can have a subcollection named "replies" as well.
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: replyDocs.length,
                  itemBuilder: (context, index) {
                    final replyDoc = replyDocs[index];
                    final replyData =
                        replyDoc.data() as Map<String, dynamic>;

                    return ThreadWidget(
                      articleId: widget.articleId,
                      docId: replyDoc.id,
                      userId: replyData['userId'] ?? '',
                      userName: replyData['userName'] ?? '',
                      text: replyData['text'] ?? '',
                      timestamp: replyData['timestamp'] as Timestamp?,
                      // For the next level, note the path:
                      //  "articulos / {articleId} / comments / {commentId} / replies / {thisReplyId} / replies"
                      // We just keep nesting "replies" subcollections:
                      repliesCollection: widget.repliesCollection
                          .doc(replyDoc.id)
                          .collection('replies'),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A small widget to handle input for posting a new reply to the current doc's "replies" subcollection.
class _ReplyInput extends StatefulWidget {
  final CollectionReference<Map<String, dynamic>> repliesCollection;

  const _ReplyInput({Key? key, required this.repliesCollection}) : super(key: key);

  @override
  State<_ReplyInput> createState() => _ReplyInputState();
}

class _ReplyInputState extends State<_ReplyInput> {
  final TextEditingController _replyController = TextEditingController();
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _replyController,
            decoration: const InputDecoration(
              hintText: 'Write a reply...',
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
                  final text = _replyController.text.trim();
                  if (text.isEmpty) return;

                  setState(() => _isPosting = true);

                  try {
                    // Add a new doc in the current doc's "replies" subcollection
                    await widget.repliesCollection.add({
                      'userId': 'someUserId',   // Replace with real user info
                      'userName': 'SomeUser',
                      'text': text,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    _replyController.clear();
                  } catch (e) {
                    debugPrint('Error posting reply: $e');
                  }

                  setState(() => _isPosting = false);
                },
        ),
      ],
    );
  }
}

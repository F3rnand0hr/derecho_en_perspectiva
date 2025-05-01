// thread_widget.dart
import 'package:derecho_en_perspectiva/data/models/comments/replyModel.dart';
import 'package:derecho_en_perspectiva/services/newCommentInput.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:derecho_en_perspectiva/cubits/authCubit.dart';
import 'package:derecho_en_perspectiva/styles/colors.dart';
import 'package:derecho_en_perspectiva/data/models/comments/commentModel.dart';
import 'package:derecho_en_perspectiva/services/replyRepo.dart';
import 'package:derecho_en_perspectiva/repositories/comments/addReply.dart';

class ThreadWidget extends StatefulWidget {
  final String articleId; // ID of the parent article
  final String docId; // Firestore doc ID of this comment/reply
  final String userId;
  final String userName;
  final String text;
  final Timestamp? timestamp;
  final CollectionReference<Map<String, dynamic>> repliesCollection;

  const ThreadWidget({
    super.key,
    required this.repliesCollection,
    required this.articleId,
    required this.docId,
    required this.userId,
    required this.userName,
    required this.text,
    this.timestamp,
  });

  @override
  State<ThreadWidget> createState() => _ThreadWidgetState();
}

class _ThreadWidgetState extends State<ThreadWidget> {
  final ThreadRepository _threadRepo = ThreadRepository();
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.spaceCadet,
                  ),
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
                style: ButtonStyle(
                  foregroundColor:
                      WidgetStateProperty.all(AppColors.spaceCadet),
                ),
                onPressed: () {
                  setState(() {
                    _showReplyField = !_showReplyField;
                  });
                },
                child: const Text(
                  'Reply',
                  selectionColor: AppColors.spaceCadet,
                ),
              ),
            ),
            // REPLY INPUT
            if (_showReplyField)
              ReplyInput(
                repliesCollection: widget.repliesCollection,
              ),
            // LIST OF CHILD REPLIES using a StreamBuilder
            StreamBuilder<List<Reply>>(
              stream: _threadRepo.getRepliesStream(widget.repliesCollection),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox();
                }
                final replies = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final reply = replies[index];
                    return ThreadWidget(
                      articleId: widget.articleId,
                      docId: reply.id,
                      userId: reply.userId,
                      userName: reply.userName,
                      text: reply.text,
                      timestamp: widget.timestamp, // or convert reply.timestamp if needed
                      // Nest the next level's replies subcollection:
                      repliesCollection: widget.repliesCollection
                          .doc(reply.id)
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

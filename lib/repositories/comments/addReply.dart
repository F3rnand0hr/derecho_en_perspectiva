import 'package:derecho_en_perspectiva/services/newCommentInput.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:derecho_en_perspectiva/cubits/authCubit.dart';
import 'package:derecho_en_perspectiva/styles/colors.dart';
import 'package:derecho_en_perspectiva/data/models/comments/commentModel.dart';
import 'package:derecho_en_perspectiva/services/replyRepo.dart';

class ReplyInput extends StatefulWidget {
  final CollectionReference<Map<String, dynamic>> repliesCollection;
  const ReplyInput({super.key, required this.repliesCollection});

  @override
  State<ReplyInput> createState() => _ReplyInputState();
}

class _ReplyInputState extends State<ReplyInput> {
  final TextEditingController _controller = TextEditingController();
  final ThreadRepository _threadRepo = ThreadRepository();
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
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
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;

                  setState(() => _isPosting = true);
                  try {
                    final user = context.read<AuthCubit>().state; // e.g. from your auth
                    final userId = user?.uid; // Extract uid from User
                    final userName = user?.displayName; // Extract displayName or similar

                    if (userId == null) {
                      debugPrint('Error: User ID is null');
                      setState(() => _isPosting = false);
                      return;
                    }

                    await _threadRepo.addReply(
                      repliesCollection: widget.repliesCollection,
                      userId: userId,
                      userName: userName ?? 'Anonymous', // Fallback if userName is null
                      text: text,
                    );

                    _controller.clear();
                  } catch (e) {
                    debugPrint('Error posting reply: $e');
                  } finally {
                    setState(() => _isPosting = false);
                  }
                },
        ),
      ],
    );
  }
}

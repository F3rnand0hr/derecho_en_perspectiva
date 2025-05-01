// new_comment_input.dart
import 'package:flutter/material.dart';

class NewCommentInput extends StatefulWidget {
  /// Callback invoked when the user taps "send".
  /// You get the entered text, and do whatever you want with it.
  final Future<void> Function(String text) onSubmit;
  final bool isPosting; // if you need a loading indicator

  const NewCommentInput({
    super.key,
    required this.onSubmit,
    this.isPosting = false,
  });

  @override
  State<NewCommentInput> createState() => _NewCommentInputState();
}

class _NewCommentInputState extends State<NewCommentInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          icon: widget.isPosting
              ? const CircularProgressIndicator()
              : const Icon(Icons.send),
          onPressed: widget.isPosting
              ? null
              : () async {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;

                  // Call the parent's onSubmit
                  await widget.onSubmit(text);

                  // Clear text if successful
                  _controller.clear();
                },
        ),
      ],
    );
  }
}

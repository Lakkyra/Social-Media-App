import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../post/domain/entities/comment.dart';
import '../../../post/presentation/cubits/post_cubits.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  AppUser? currentUser;
  bool isOwnComment = false;
  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnComment = (currentUser?.uid == widget.comment.userId);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void showOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Comment?'),

          actions: [
            TextButton(
              onPressed: () {
                context.read<PostCubit>().deleteCommentFromPost(
                  widget.comment.postId,
                  widget.comment.id,
                );
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          Text(
            widget.comment.userName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Text(widget.comment.text),
          const Spacer(),
          if (isOwnComment)
            IconButton(
              onPressed: showOptions,
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
    );
  }
}

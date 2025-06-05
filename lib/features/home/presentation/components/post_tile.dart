import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/components/my_text_field.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../post/domain/entities/comment.dart';
import '../../../post/domain/entities/post.dart';
import '../../../post/presentation/cubits/post_cubits.dart';
import '../../../post/presentation/cubits/post_states.dart';
import '../../../profile/domain/entities/profile_user.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'comment_tile.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final profileCubit = context.read<ProfileCubit>();
  late final postCubit = context.read<PostCubit>();
  late final authCubit = context.read<AuthCubit>();
  final _commentController = TextEditingController();
  bool isOwnPost = false;
  AppUser? currentUser;
  ProfileUser? postUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    currentUser = authCubit.currentUser;
    isOwnPost = currentUser?.uid == widget.post.userId;
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  void toggleLikePost() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    if (isLiked) {
      // If the post is already liked, we remove the like
      setState(() {
        widget.post.likes.remove(currentUser!.uid);
      });
    } else {
      // If the post is not liked, we add the like
      setState(() {
        widget.post.likes.add(currentUser!.uid);
      });
    }
    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((
      error,
    ) {
      setState(() async {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  void showOptions() {
    showDialog(
      context: context,
      builder: (context) {
        print(postUser);
        return AlertDialog(
          title: const Text('Delete Post?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onDeletePressed?.call();
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

  void openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a Comment'),
          content: MyTextField(
            controller: _commentController,
            hintText: 'Write your comment',
            obscureText: false,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final commentText = _commentController.text;

                if (commentText.isNotEmpty) {
                  Comment comment = Comment(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: currentUser!.uid,
                    userName: currentUser!.name,

                    text: commentText,
                    timeStamp: DateTime.now(),
                    postId: widget.post.id,
                  );
                  postCubit.addCommentToPost(widget.post.id, comment);
                  _commentController.clear();
                }
                Navigator.pop(context);
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(uid: widget.post.userId),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (postUser?.profileImageUrl != null)
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageUrl,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : const Icon(Icons.person),
                  const SizedBox(width: 10),
                  Text(widget.post.userName),
                  const Spacer(),
                  if (isOwnPost)
                    IconButton(
                      onPressed: showOptions,
                      icon: const Icon(Icons.delete),
                    ),
                ],
              ),
            ),
          ),

          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            errorWidget: (context, url, error) => Center(
              child: Icon(
                Icons.error,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: toggleLikePost,
                  icon: Icon(
                    (widget.post.likes.contains(currentUser!.uid))
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: (widget.post.likes.contains(currentUser!.uid))
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(widget.post.likes.length.toString()),
                IconButton(
                  onPressed: openNewCommentBox,
                  icon: Icon(Icons.comment),
                ),
                Text(widget.post.comments.length.toString()),
                Spacer(),
                Text(widget.post.timeStamp.toString()),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              children: [
                Text(
                  widget.post.userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Text(widget.post.text),
              ],
            ),
          ),

          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              if (state is PostLoaded) {
                final post = widget.post;
                if (post.comments.isNotEmpty) {
                  int showCommentCount = post.comments.length;
                  return ListView.builder(
                    itemCount: showCommentCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final comment = post.comments[index];
                      return CommentTile(comment: comment);
                    },
                  );
                }
              }
              if (state is PostLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is PostError) {
                return Center(child: Text(state.errorMessage));
              } else {
                return Center(child: Text('No comments yet'));
              }
            },
          ),
        ],
      ),
    );
  }
}

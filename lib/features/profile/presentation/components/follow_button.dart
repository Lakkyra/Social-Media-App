import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final void Function()? onFollowPressed;
  final bool isFollowing;
  const FollowButton({
    super.key,
    required this.onFollowPressed,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MaterialButton(
          onPressed: onFollowPressed,
          padding: const EdgeInsets.all(25),
          color: isFollowing
              ? Theme.of(context).colorScheme.primary
              : Colors.blue,
          child: Text(
            isFollowing ? 'Unfollow' : 'Follow',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

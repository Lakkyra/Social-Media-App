import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int postCount;
  final int followerCount;
  final int followingCount;
  final void Function()? onTap;
  const ProfileStats({
    super.key,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(children: [Text(postCount.toString()), const Text('Posts')]),
          Column(
            children: [Text(followerCount.toString()), const Text('Followers')],
          ),
          Column(
            children: [
              Text(followingCount.toString()),
              const Text('Following'),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../home/presentation/components/post_tile.dart';
import '../../../post/presentation/cubits/post_cubits.dart';
import '../../../post/presentation/cubits/post_states.dart';
import '../../../responsive/constrained_scaffold.dart';
import '../components/bio_box.dart';
import '../components/follow_button.dart';
import '../components/profile_stats.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_states.dart';
import 'edit_profile_page.dart';
import 'followers_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  late final postCubit = context.read<PostCubit>();
  late AppUser? currentUser = authCubit.currentUser;
  int postCount = 0;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    profileCubit.fetchUserProfile(widget.uid);
  }

  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoadedState) {
      return;
    }
    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);
    if (isFollowing) {
      setState(() {
        profileUser.followers.remove(currentUser!.uid);
      });
    } else {
      setState(() {
        profileUser.followers.add(currentUser!.uid);
      });
    }
    profileCubit.toggleFollower(currentUser!.uid, widget.uid).catchError((e) {
      setState(() {
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        } else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnProfile = (currentUser?.uid == widget.uid);
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoadedState) {
          final user = state.profileUser;

          return ConstrainedScaffold(
            appBar: AppBar(
              title: Text(
                user.name,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              centerTitle: true,
              actions: [
                isOwnProfile
                    ? IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfilePage(profileUser: user),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.settings,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : SizedBox(),
              ],
            ),
            body: ListView(
              children: [
                Center(
                  child: Text(
                    user.email,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  height: 120,
                  width: 120,
                  padding: const EdgeInsets.all(25),
                  child: (user.profileImageUrl.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : CachedNetworkImage(
                          imageUrl: user.profileImageUrl,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          imageBuilder: (context, imageProvider) =>
                              Image(image: imageProvider, fit: BoxFit.cover),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 72,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
                BlocBuilder<PostCubit, PostState>(
                  builder: (context, state) {
                    if (state is PostLoaded) {
                      return ProfileStats(
                        postCount: state.posts
                            .where((post) => post.userId == user.uid)
                            .toList()
                            .length,
                        followerCount: user.followers.length,
                        followingCount: user.following.length,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FollowersPage(
                              followers: user.followers,
                              following: user.following,
                            ),
                          ),
                        ),
                      );
                    }
                    return Center(child: Text('error fetching profile stats'));
                  },
                ),

                const SizedBox(height: 25),
                !isOwnProfile
                    ? FollowButton(
                        onFollowPressed: followButtonPressed,
                        isFollowing: user.followers.contains(currentUser!.uid),
                      )
                    : SizedBox(),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(children: [Text('Bio')]),
                ),
                const SizedBox(height: 10),
                BioBox(bio: user.bio),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(children: [Text('Posts')]),
                ),

                BlocBuilder<PostCubit, PostState>(
                  builder: (context, state) {
                    if (state is PostLoaded) {
                      final userPosts = state.posts
                          .where((post) => post.userId == user.uid)
                          .toList();

                      postCount = userPosts.length;

                      return ListView.builder(
                        itemCount: postCount,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return PostTile(
                            post: userPosts[index],
                            onDeletePressed: () {
                              context.read<PostCubit>().deletePost(
                                userPosts[index].id,
                              );
                            },
                          );
                        },
                      );
                    }
                    if (state is PostLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    } else {
                      return Center(child: Text('No posts available'));
                    }
                  },
                ),
              ],
            ),
          );
        } else if (state is ProfileLoadingState) {
          return ConstrainedScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Center(child: Text('No profile found ...'));
        }
      },
    );
  }
}

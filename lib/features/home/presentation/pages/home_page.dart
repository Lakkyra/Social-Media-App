import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../post/presentation/cubits/post_cubits.dart';
import '../../../post/presentation/cubits/post_states.dart';
import '../../../post/presentation/pages/upload_post_page.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_states.dart';
import '../../../responsive/constrained_scaffold.dart';
import '../components/my_drawer.dart';

import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../components/post_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  late final AppUser? currentUser = authCubit.currentUser;
  late final postCubit = context.read<PostCubit>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    postCubit.fetchAllPosts();
    profileCubit.fetchUserProfile(currentUser!.uid);
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoadedState) {
          final profileUser = state.profileUser;
          return ConstrainedScaffold(
            appBar: AppBar(
              title: const Text('Home Page'),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UploadPostPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            drawer: MyDrawer(profileUser: profileUser),
            body: BlocBuilder<PostCubit, PostState>(
              builder: (context, state) {
                if (state is PostLoading || state is PostLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                } else if (state is PostLoaded) {
                  final allPosts = state.posts;

                  if (allPosts.isEmpty) {
                    return Center(
                      child: Text(
                        'No posts available',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: allPosts.length,
                      itemBuilder: (context, index) {
                        final post = allPosts[index];
                        return PostTile(
                          post: post,
                          onDeletePressed: () => deletePost(post.id),
                        );
                      },
                    );
                  }
                } else if (state is PostError) {
                  return Center(child: Text(state.errorMessage));
                }
                return Center();
              },
            ),
          );
        }
        return ConstrainedScaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}

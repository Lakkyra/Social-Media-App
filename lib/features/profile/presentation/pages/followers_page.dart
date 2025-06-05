import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../responsive/constrained_scaffold.dart';
import '../components/user_tile.dart';
import '../cubit/profile_cubit.dart';

class FollowersPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;
  const FollowersPage({
    super.key,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ConstrainedScaffold(
        appBar: AppBar(
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,

            tabs: [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(followers, 'No followers', context),
            _buildUserList(following, 'Not following anyone', context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(
    List<String> users,
    String emptyMessage,
    BuildContext context,
  ) {
    return (users.isEmpty)
        ? Center(child: Text(emptyMessage))
        : ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final uid = users[index];
              return FutureBuilder(
                future: context.read<ProfileCubit>().getUserProfile(uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final user = snapshot.data;
                    return UserTile(user: user);
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text('Loading...'));
                  } else {
                    return ListTile(title: Text('User not found.'));
                  }
                },
              );
            },
          );
  }
}

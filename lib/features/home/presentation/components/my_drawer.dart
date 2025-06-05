import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubits/auth_cubit.dart';

import '../../../profile/domain/entities/profile_user.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import 'my_drawer_tile.dart';

class MyDrawer extends StatelessWidget {
  final ProfileUser profileUser;
  const MyDrawer({super.key, required this.profileUser});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: (profileUser.profileImageUrl.isEmpty)
                    ? Icon(
                        Icons.person,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : CachedNetworkImage(
                        imageUrl: profileUser.profileImageUrl,
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
              Divider(color: Theme.of(context).colorScheme.secondary),
              MyDrawerTile(title: 'H O M E', icon: Icons.home, onTap: () {}),
              MyDrawerTile(
                title: 'P R O F I L E',
                icon: Icons.person,
                onTap: () {
                  Navigator.pop(context); // Close the drawer before navigating

                  final user = context.read<AuthCubit>().currentUser;
                  String? uid = user!.uid;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(uid: uid),
                    ),
                  );
                },
              ),
              MyDrawerTile(
                title: 'S E A R C H',
                icon: Icons.search,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  );
                },
              ),
              MyDrawerTile(
                title: 'S E T T I N G S',
                icon: Icons.settings,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
              Spacer(),
              MyDrawerTile(
                title: 'L O G O U T',
                icon: Icons.logout,
                onTap: () {
                  // Implement logout functionality here
                  // Close the drawer
                  context.read<AuthCubit>().logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

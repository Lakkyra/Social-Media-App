import 'package:flutter/material.dart';

import '../../domain/entities/profile_user.dart';
import '../pages/profile_page.dart';

class UserTile extends StatelessWidget {
  final ProfileUser? user;
  const UserTile({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user!.name),
      trailing: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(uid: user!.uid),
            ),
          );
        },
        icon: Icon(Icons.arrow_right_alt),
      ),
    );
  }
}

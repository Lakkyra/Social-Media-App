import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../themes/cubits/theme_cubit.dart';
import '../../../responsive/constrained_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    bool isDarkMode = themeCubit.isDarkMode;
    return ConstrainedScaffold(
      appBar: AppBar(title: Text('Settings'), centerTitle: true),
      body: Column(
        children: [
          ListTile(
            title: Text('Dark Mode'),
            trailing: CupertinoSwitch(
              value: isDarkMode,
              onChanged: (value) => themeCubit.toggleTheme(),
            ),
          ),
        ],
      ),
    );
  }
}

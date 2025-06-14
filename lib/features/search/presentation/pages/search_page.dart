import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/presentation/components/user_tile.dart';
import '../../../responsive/constrained_scaffold.dart';
import '../cubits/search_cubit.dart';
import '../cubits/search_states.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late final searchCubit = context.read<SearchCubit>();

  void onSearchChanged() {
    final query = _searchController.text;
    searchCubit.searchusers(query);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search users...',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchLoaded) {
            if (state.users.isEmpty) {
              return const Center(child: Text('No users found...'));
            }
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return UserTile(user: user);
              },
            );
          } else if (state is SearchLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SearchError) {
            return Center(child: Text(state.errorMessage));
          }
          return Center(child: Text('Start searching for users...'));
        },
      ),
    );
  }
}

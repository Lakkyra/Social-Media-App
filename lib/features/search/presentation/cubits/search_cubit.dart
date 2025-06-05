import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/search_repo.dart';
import 'search_states.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo searchRepo;
  SearchCubit({required this.searchRepo}) : super(SearchInitial());

  Future<void> searchusers(String query) async {
    try {
      if (query.isEmpty) {
        emit(SearchInitial());
        return;
      } else {
        emit(SearchLoading());
        final users = await searchRepo.searchUsers(query);
        emit(SearchLoaded(users));
      }
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}

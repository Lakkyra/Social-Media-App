import '../../../profile/domain/entities/profile_user.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ProfileUser?> users;

  SearchLoaded(this.users);
}

class SearchError extends SearchState {
  final String errorMessage;

  SearchError(this.errorMessage);
}

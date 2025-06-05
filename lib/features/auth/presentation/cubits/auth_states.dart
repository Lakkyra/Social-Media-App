import '../../domain/entities/app_user.dart';

abstract class AuthState {}

//initial state
class AuthInitialState extends AuthState {}

//loading
class AuthLoadingState extends AuthState {}

//authenticated
class AuthenticatedState extends AuthState {
  final AppUser appUser;
  AuthenticatedState({required this.appUser});
}

//unauthenticated
class UnauthenticatedState extends AuthState {}

//error
class AuthErrorState extends AuthState {
  final String errorMessage;
  AuthErrorState({required this.errorMessage});
}

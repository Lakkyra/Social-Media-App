import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repos/auth_repo.dart';
import 'auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitialState());

  //check if user is authenticated

  void checkAuth() async {
    final user = await authRepo.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      emit(AuthenticatedState(appUser: user));
    } else {
      emit(UnauthenticatedState());
    }
  }

  AppUser? get currentUser => _currentUser;

  Future<void> login(String email, String password) async {
    emit(AuthLoadingState());
    try {
      final user = await authRepo.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        _currentUser = user;
        emit(AuthenticatedState(appUser: user));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(errorMessage: e.toString()));
      emit(UnauthenticatedState());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(AuthLoadingState());
    try {
      final user = await authRepo.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      if (user != null) {
        _currentUser = user;
        emit(AuthenticatedState(appUser: user));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(errorMessage: e.toString()));
      emit(UnauthenticatedState());
    }
  }

  Future<void> logout() async {
    authRepo.logout();
    emit(UnauthenticatedState());
  }
}

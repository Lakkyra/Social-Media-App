import '../entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });
  Future<AppUser?> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}

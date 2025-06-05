import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/features/auth/domain/entities/app_user.dart';

import '../domain/repos/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredentials = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot userDoc = await firebaseFirestore
          .collection('users')
          .doc(userCredentials.user!.uid)
          .get();
      AppUser appUser = AppUser(
        uid: userCredentials.user!.uid,
        email: email,
        name: userDoc['name'],
      );
      return appUser;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredentials = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      AppUser appUser = AppUser(
        uid: userCredentials.user!.uid,
        email: email,
        name: name,
      );
      await firebaseFirestore
          .collection('users')
          .doc(appUser.uid)
          .set(appUser.toJson());
      return appUser;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    DocumentSnapshot userDoc = await firebaseFirestore
        .collection('users')
        .doc(_firebaseAuth.currentUser?.uid)
        .get();
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      return AppUser(uid: user.uid, email: user.email!, name: userDoc['name']);
    }
    return null; // No user is currently signed in
  }
}

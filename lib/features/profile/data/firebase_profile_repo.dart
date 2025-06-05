import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/profile_user.dart';
import '../domain/repo/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      final userDoc = await firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          final followers = List<String>.from(userData['followers'] ?? []);
          final following = List<String>.from(userData['following'] ?? []);
          return ProfileUser(
            uid: uid,
            email: userData['email'],
            name: userData['name'],
            bio: userData['bio'] ?? '',
            profileImageUrl: userData['profileImageUrl'].toString(),
            followers: followers,
            following: following,
          );
        }
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<void> updateUserProfile(ProfileUser updatedProfile) async {
    try {
      await firestore.collection('users').doc(updatedProfile.uid).update({
        'bio': updatedProfile.bio,
        'profileImageUrl': updatedProfile.profileImageUrl,
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> toggleFollower(String currentUserId, String targetUserId) async {
    try {
      final currentUserDoc = await firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      final targetUserDoc = await firestore
          .collection('users')
          .doc(targetUserId)
          .get();
      if (currentUserDoc.exists && targetUserDoc.exists) {
        final currentUserData = currentUserDoc.data();
        final targetUserData = targetUserDoc.data();

        if (currentUserData != null && targetUserData != null) {
          final targetFollowers = List<String>.from(
            targetUserData['followers'] ?? [],
          );

          if (targetFollowers.contains(currentUserId)) {
            await firestore.collection('users').doc(currentUserId).update({
              'following': FieldValue.arrayRemove([targetUserId]),
            });

            await firestore.collection('users').doc(targetUserId).update({
              'followers': FieldValue.arrayRemove([currentUserId]),
            });

            // Unfollow
          } else {
            // Follow
            await firestore.collection('users').doc(currentUserId).update({
              'following': FieldValue.arrayUnion([targetUserId]),
            });
            await firestore.collection('users').doc(targetUserId).update({
              'followers': FieldValue.arrayUnion([currentUserId]),
            });
          }
        }
      }
    } catch (e) {}
  }
}

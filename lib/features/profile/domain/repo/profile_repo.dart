import '../entities/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser?> fetchUserProfile(String uid);
  Future<void> updateUserProfile(ProfileUser updatedProfile);
  Future<void> toggleFollower(String currentUserId, String targetUserId);
}

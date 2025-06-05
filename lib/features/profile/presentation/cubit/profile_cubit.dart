import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/cloudinary_services.dart';
import '../../domain/entities/profile_user.dart';
import '../../domain/repo/profile_repo.dart';
import 'profile_states.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  ProfileCubit({required this.profileRepo}) : super(ProfileInitialState());

  Future<void> fetchUserProfile(String uid) async {
    emit(ProfileLoadingState());
    try {
      final profileUser = await profileRepo.fetchUserProfile(uid);
      if (profileUser != null) {
        emit(ProfileLoadedState(profileUser: profileUser));
      } else {
        emit(ProfileErrorState(errorMessage: 'pata nhi'));
      }
    } catch (e) {
      emit(ProfileErrorState(errorMessage: e.toString()));
    }
  }

  Future<ProfileUser?> getUserProfile(String uid) async {
    final profileUser = await profileRepo.fetchUserProfile(uid);
    return profileUser;
  }

  Future<void> updateUserProfile(
    String uid,
    String? bio,

    PlatformFile? platformFile,
    Uint8List? webBytes,
  ) async {
    emit(ProfileLoadingState());
    try {
      final currentUser = await profileRepo.fetchUserProfile(uid);
      if (currentUser == null) {
        emit(ProfileErrorState(errorMessage: 'User not found'));
        return;
      }
      final imageUrl = await uploadToCloudinary(
        platformFile: platformFile,
        webBytes: webBytes,
        folder: 'profile_images',
      );
      if (imageUrl.isNotEmpty) {
        await deleteFromCloudinary(currentUser.profileImageUrl);
      }
      final updatedProfile = currentUser.copyWith(
        newBio: bio ?? currentUser.bio,
        newProfileImageUrl: (imageUrl.isNotEmpty)
            ? imageUrl
            : currentUser.profileImageUrl,
      );

      await profileRepo.updateUserProfile(updatedProfile);
      await fetchUserProfile(uid); // Refresh the profile after update
      emit(ProfileLoadedState(profileUser: updatedProfile));
    } catch (e) {
      emit(ProfileErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> toggleFollower(String currentUserId, String targetUserId) async {
    try {
      await profileRepo.toggleFollower(currentUserId, targetUserId);
      // Optionally, you can fetch the updated profile after toggling the follower
    } catch (e) {
      emit(ProfileErrorState(errorMessage: e.toString()));
    }
  }
}

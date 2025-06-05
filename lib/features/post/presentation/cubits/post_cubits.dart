import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/cloudinary_services.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repo/post_repo.dart';
import 'post_states.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;

  PostCubit({required this.postRepo}) : super(PostInitial());

  Future<void> createPost(
    Post post,
    PlatformFile? imagePath,
    Uint8List? imageBytes,
  ) async {
    try {
      String? imageUrl;
      if (imagePath != null || imageBytes != null) {
        emit(PostUploading());
        imageUrl = await uploadToCloudinary(
          platformFile: imagePath,
          webBytes: imageBytes,
          folder: 'posts',
        );
      }

      final newPost = post.copyWith(imageUrl: imageUrl);
      postRepo.createPost(newPost);
      final posts = await postRepo.fetchAllPosts();

      emit(PostLoaded(posts: posts));
    } catch (e) {
      emit(PostError(errorMessage: e.toString()));
    }
  }

  Future<void> fetchAllPosts() async {
    emit(PostLoading());
    try {
      final posts = await postRepo.fetchAllPosts();
      emit(PostLoaded(posts: posts));
    } catch (e) {
      emit(PostError(errorMessage: e.toString()));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      emit(PostLoading());
      await postRepo.deletePost(postId);

      final posts = await postRepo.fetchAllPosts();
      emit(PostLoaded(posts: posts));
    } catch (e) {
      emit(PostError(errorMessage: e.toString()));
    }
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostError(errorMessage: e.toString()));
    }
  }

  Future<void> addCommentToPost(String postId, Comment comment) async {
    try {
      await postRepo.addCommentToPost(postId, comment);
      await fetchAllPosts();
    } catch (e) {
      emit(PostError(errorMessage: e.toString()));
    }
  }

  Future<void> deleteCommentFromPost(String postId, String commentId) async {
    try {
      await postRepo.deleteCommentFromPost(postId, commentId);
      await fetchAllPosts();
    } catch (e) {
      emit(PostError(errorMessage: e.toString()));
    }
  }
}

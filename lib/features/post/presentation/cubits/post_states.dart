import '../../domain/entities/post.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;

  PostLoaded({required this.posts});
}

class PostUploading extends PostState {}

class PostError extends PostState {
  final String errorMessage;

  PostError({required this.errorMessage});
}

import '../entities/comment.dart';
import '../entities/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllPosts();
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<List<Post>> fetchPostsByUser(String userId);
  Future<void> toggleLikePost(String postId, String userId);
  Future<void> addCommentToPost(String postId, Comment comment);
  Future<void> deleteCommentFromPost(String postId, String commentId);
}

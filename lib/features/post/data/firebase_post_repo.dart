import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/features/post/domain/entities/comment.dart';

import 'package:instagram/features/post/domain/entities/post.dart';

import '../domain/repo/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference postsCollection = FirebaseFirestore.instance
      .collection('posts');
  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      final postSnapshot = await postsCollection
          .orderBy('timeStamp', descending: true)
          .get();
      final List<Post> posts = postSnapshot.docs.map((doc) {
        return Post.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      return posts;
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  @override
  Future<List<Post>> fetchPostsByUser(String userId) async {
    try {
      final postSnapshot = await postsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timeStamp', descending: true)
          .get();
      final List<Post> posts = postSnapshot.docs.map((doc) {
        return Post.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      return posts;
    } catch (e) {
      throw Exception('Failed to fetch posts by user: $e');
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      final postDoc = postsCollection.doc(postId);
      final postSnapshot = await postDoc.get();
      if (postSnapshot.exists) {
        final post = Post.fromJson(postSnapshot.data() as Map<String, dynamic>);
        final hasLiked = post.likes.contains(userId);
        if (hasLiked) {
          // User has already liked the post, remove like
          post.likes.remove(userId);
        } else {
          // User has not liked the post, add like
          post.likes.add(userId);
        }
        await postDoc.update({'likes': post.likes});
      } else {
        throw Exception('Post does not exist');
      }
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  @override
  Future<void> addCommentToPost(String postId, Comment comment) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        post.comments.add(comment);
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList(),
        });
      } else {
        throw Exception('Post does not exist');
      }
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  @override
  Future<void> deleteCommentFromPost(String postId, String commentId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        post.comments.removeWhere((comment) => comment.id == commentId);
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList(),
        });
      } else {
        throw Exception('Post does not exist');
      }
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }
}

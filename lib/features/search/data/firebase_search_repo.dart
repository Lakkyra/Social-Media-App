import 'package:cloud_firestore/cloud_firestore.dart';

import '../../profile/domain/entities/profile_user.dart';
import '../domain/search_repo.dart';

class FirebaseSearchRepo implements SearchRepo {
  @override
  Future<List<ProfileUser?>> searchUsers(String query) async {
    try {
      final results = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThan: query)
          .where('name', isLessThan: "$query\uf8ff")
          .get();
      return results.docs
          .map((doc) => ProfileUser.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error searching user: $e');
    }
  }
}

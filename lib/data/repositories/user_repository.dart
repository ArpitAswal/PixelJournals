import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';
import '../../data/models/user_model.dart';

class UserRepository {
  UserRepository()
    : _auth = FirebaseAuth.instance, // FirebaseAuth instance
      _firestore = FirebaseFirestore.instance; // FirebaseFirestore instance

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String get currentUserId => _auth.currentUser!.uid;

  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .snapshots()
        .map((snapshot) {
          return snapshot
              .docs // Get all users
              .map((doc) => UserModel.fromMap(doc.data()))
              .where(
                (user) => user.userId != currentUserId,
              ) // Exclude current user
              .toList();
        });
  }

  Stream<List<UserModel>> getFollowingUsers() {
    return _firestore
        .collection(FirebaseConstants.followingCollection)
        .doc(currentUserId)
        .collection(FirebaseConstants.followingUsersId)
        .snapshots() // Get the list of followed users Id
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => UserModel.fromMap(doc.data()),
              ) // Get the user model of each followed user
              .toList();
        });
  }

  Future<bool> toggleFollow(UserModel targetUser) async {
    final followRef = _firestore
        .collection(FirebaseConstants.followingCollection)
        .doc(currentUserId)
        .collection(FirebaseConstants.followingUsersId)
        .doc(targetUser.userId); // Reference to the followed user document

    final doc = await followRef.get(); // Check if the user is already followed
    if (doc.exists) {
      await followRef
          .delete(); // If the user is already followed, unfollow them
      return false;
    } else {
      await followRef.set(
        targetUser.toMap(),
      ); // If the user is not followed, follow them by saving user info
      return true;
    }
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../models/chat_model.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class PostsRepository {
  PostsRepository()
    : auth = FirebaseAuth.instance, // FirebaseAuth instance
      _firestore = FirebaseFirestore.instance, // FirebaseFirestore instance
      _storage = storage.FirebaseStorage.instance; // FirebaseStorage instance

  final FirebaseAuth auth;

  final FirebaseFirestore _firestore;
  final ImagePicker _imagePicker = ImagePicker();
  final storage.FirebaseStorage _storage;

  Stream<List<PostModel>> getPosts() {
    // Get current user's posts stream
    Stream<List<PostModel>> currentUserPosts = _firestore
        .collection(FirebaseConstants.postsCollection)
        .doc(auth.currentUser!.uid)
        .collection(FirebaseConstants.userPostsCollection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PostModel.fromMap(doc.data()))
                  .toList(),
        );

    // Get followed users' posts streams
    Stream<List<PostModel>> followedUsersPosts = _firestore
        .collection(FirebaseConstants.followingCollection)
        .doc(auth.currentUser!.uid)
        .collection(FirebaseConstants.followingUsersId)
        .snapshots() // Get the list of followed users Id
        .asyncMap((followingSnapshot) async {
          // Get the posts of followed users
          List<List<PostModel>> allFollowedUsersPosts = await Future.wait(
            // Fetch posts for each followed user
            followingSnapshot.docs.map((followingDoc) {
              // For each followed user, get their posts
              return _firestore
                  .collection(FirebaseConstants.postsCollection)
                  .doc(followingDoc.id) // followed user Id
                  .collection(FirebaseConstants.userPostsCollection)
                  .get() // Get the posts of the followed user
                  .then(
                    (postsSnapshot) =>
                        postsSnapshot.docs
                            .map((doc) => PostModel.fromMap(doc.data()))
                            .toList(),
                  );
            }),
          );

          return allFollowedUsersPosts
              .expand((posts) => posts)
              .toList(); // Flatten the list of lists into a single list
        });
    // Combine the streams of current user's posts and followed users' posts
    return Rx.combineLatest2(currentUserPosts, followedUsersPosts, (
      List<PostModel> currentPosts,
      List<PostModel> followedPosts,
    ) {
      List<PostModel> allPosts = [
        ...currentPosts,
        ...followedPosts,
      ]; // Combine the posts, here spread operator is used to combine the two lists
      allPosts.sort(
        (a, b) => b.postTimeStamp.compareTo(a.postTimeStamp),
      ); // Sort the posts by timestamp in descending order
      return allPosts;
    });
  }

  Future<void> createPost(File image, String description) async {
    final imageUrl = await _uploadImage(image);
    final postId = const Uuid().v4();
    final post = PostModel(
      postId: postId,
      postTimeStamp: Timestamp.now(),
      postUrl: imageUrl,
      postDescription: description,
      userId: auth.currentUser!.uid,
    );

    final userDocRef = _firestore
        .collection(FirebaseConstants.postsCollection)
        .doc(auth.currentUser!.uid)
        .collection(FirebaseConstants.userPostsCollection);

    await userDocRef
        .doc(postId)
        .set(post.toMap()); // Save the post to Firestore by post Id
  }

  Future<void> updateUserProfile(
    // Update user profile information
    String? userName,
    String? userProfileUrl,
  ) async {
    final userDocRef = _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(auth.currentUser!.uid);
    await userDocRef.update({
      if (userName != null) "userName": userName,
      if (userProfileUrl != null) "userProfileUrl": userProfileUrl,
    });
  }

  Future<void> deletePost(String postId) async {
    final userDocRef = _firestore
        .collection(FirebaseConstants.postsCollection)
        .doc(auth.currentUser!.uid)
        .collection(FirebaseConstants.userPostsCollection);
    await userDocRef
        .doc(postId)
        .delete(); // Delete the post from Firestore by postId
  }

  Future<XFile?> pickImage(ImageSource source) async {
    return await _imagePicker.pickImage(
      // Pick an image from the gallery or camera
      source: source,
      imageQuality: null,
    );
  }

  Stream<List<ChatModel>> getChatMessages(String postId) {
    // Fetch chat messages for a specific post
    return _firestore
        .collection("posts")
        .doc(postId)
        .collection("chat")
        .orderBy("timeStamp")
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatModel.fromSnapshot(doc))
                  .toList(), // Convert each document to ChatModel
        );
  }

  Future<void> sendMessage(String postId, String message) async {
    // Send a chat message
    await _firestore.collection("posts").doc(postId).collection("chat").add({
      "userID": auth.currentUser!.uid,
      "userName": auth.currentUser!.displayName,
      "message": message,
      "timeStamp": Timestamp.now(),
    });
  }

  Future<void> logout() async {
    await auth.signOut(); // Sign out the user
  }

  Stream<List<PostModel>> queryPosts(String searchQuery) {
    // Search for posts by description
    return _firestore
        .collection(FirebaseConstants.postsCollection)
        .doc(auth.currentUser!.uid)
        .collection(FirebaseConstants.userPostsCollection)
        .orderBy(
          "postTimeStamp",
          descending: true,
        ) // return the posts, order by timestamp
        .snapshots()
        .map((snapshot) {
          final posts =
              snapshot.docs
                  .map((doc) => PostModel.fromMap(doc.data()))
                  .toList(); // Convert each document to PostModel
          return posts
              .where(
                (post) => post.postDescription.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
              )
              .toList(); // Filter posts by description
        });
  }

  Future<UserModel?> postDetail(String userId) async {
    return await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .get()
        .then((onValue) {
          // Fetch user details for a specific post
          if (onValue.exists) {
            return UserModel.fromMap(onValue.data()!);
          } else {
            return null; // Return null if user does not exist
          }
        });
  }

  Future<void> postLiked(bool isLiked, String postId) async {
    // current auth like this post or not, if yes then save it on Firestore Firebase otherwise delete it.
    final path = _firestore
        .collection(FirebaseConstants.likedCollection)
        .doc(auth.currentUser!.uid);
    final doc = await path.get();
    if (doc.exists) {
      if (isLiked) {
        path.update({
          'postIDs': FieldValue.arrayUnion(
            [postId],
          ), // Each specified element that doesn't already exist in the array will be added to the end. If the field being modified is not already an array it will be overwritten with an array containing exactly the specified elements.
        });
      } else {
        path.update({
          'postIDs': FieldValue.arrayRemove(
            [postId],
          ), // All instances of each element specified will be removed from the array. If the field being modified is not already an array it will be overwritten with an empty array.
        });
      }
    } else {
      path.set({
        'postIDs': [postId], // set the list with post id
      });
    }
  }

  Future<bool> isPostLiked(String postId) async {
    final data =
        await _firestore
            .collection(FirebaseConstants.likedCollection)
            .doc(auth.currentUser!.uid)
            .get();
    if (data.exists && data.data() != null) {
      // Convert List<dynamic> to List<String>
      final List<dynamic> dynamicList =
          data.data()!['postIDs'] as List<dynamic>;
      final List<String> postIds =
          dynamicList.map((e) => e.toString()).toList();
      if (postIds.contains(postId)) {
        // if the postId contain means the post is already liked otherwise not.
        return true;
      }
      return false;
    } else {
      // if data does not exist, means the current auth user does not like any post yet!.
      return false;
    }
  }

  Future<String> _uploadImage(File image) async {
    final postId = const Uuid().v4(); // Generate a unique post ID
    final ref = _storage.ref(
      "${FirebaseConstants.userPostStorageReference}/${auth.currentUser!.uid}/$postId.png", // Storage reference for the image
    );
    final taskSnapshot = await ref.putFile(image);
    return await taskSnapshot.ref
        .getDownloadURL(); // Get the download URL of the uploaded image
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../models/chat_model.dart';
import '../models/post_model.dart';

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
    // Fetch posts from Firestore
    return _firestore
        .collection(FirebaseConstants.postsCollection)
        .doc(auth.currentUser!.uid)
        .collection(FirebaseConstants.userPostsCollection)
        .orderBy("postTimeStamp", descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PostModel.fromMap(doc.data()))
                  .toList(), // Convert each document to PostModel
        );
  }

  Future<void> createPost(File image, String description) async {
    // Create a new post
    final imageUrl = await _uploadImage(image);
    final postId = const Uuid().v4(); // Generate a unique post ID
    final post = PostModel(
      postId: postId,
      postTimeStamp: Timestamp.now(),
      postUrl: imageUrl,
      postDescription: description.toLowerCase(),
    );

    final userDocRef = _firestore
        .collection(FirebaseConstants.postsCollection)
        .doc(auth.currentUser!.uid)
        .collection(FirebaseConstants.userPostsCollection);

    await userDocRef
        .doc(postId)
        .set(post.toMap()); // Save the post to Firestore
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
    await userDocRef.doc(postId).delete(); // Delete the post from Firestore
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
              .where((post) => post.postDescription.contains(searchQuery))
              .toList(); // Filter posts by description
        });
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

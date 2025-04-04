import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  PostModel({
    required this.postId,
    required this.postTimeStamp,
    required this.postUrl,
    required this.postDescription,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'] as String,
      postTimeStamp: map['postTimeStamp'] as Timestamp,
      postUrl: map['postUrl'] as String,
      postDescription: map['postDescription'] as String,
    );
  }

  final String postDescription;
  final String postId;
  final Timestamp postTimeStamp;
  final String postUrl;

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'postTimeStamp': postTimeStamp,
      'postUrl': postUrl,
      'postDescription': postDescription,
    };
  }
}

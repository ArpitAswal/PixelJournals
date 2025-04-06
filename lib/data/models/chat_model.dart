import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  ChatModel({
    required this.timestamp,
    required this.message,
    required this.username,
    required this.userID,
  });

  ChatModel.fromSnapshot(QueryDocumentSnapshot doc)
    : userID = doc["userID"] as String,
      username = doc["userName"] as String,
      timestamp = doc["timeStamp"] as Timestamp,
      message = doc["message"] as String;

  final String message;
  final Timestamp timestamp;
  final String userID;
  final String username;
}

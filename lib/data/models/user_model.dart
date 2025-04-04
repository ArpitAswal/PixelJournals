import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.deviceToken = '',
    this.isEmailVerified = false,
    this.userProfile,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      userId: doc['userId'] as String,
      userName: doc['userName'] as String,
      userEmail: doc['userEmail'] as String,
      deviceToken: doc['deviceToken'] as String,
      isEmailVerified: doc['isEmailVerified'],
      userProfile: doc['userProfile']?.toString(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      deviceToken: map['deviceToken'] ?? '',
      isEmailVerified: map['isEmailVerified'] ?? false,
      userProfile: map['userProfile']?.toString(),
    );
  }

  final String deviceToken;
  final bool isEmailVerified;
  final String userEmail;
  final String userId;
  final String userName;
  final String? userProfile;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'deviceToken': deviceToken,
      'isEmailVerified': isEmailVerified,
      'userProfile': userProfile,
    };
  }
}

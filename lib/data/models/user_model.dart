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
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }

    return UserModel(
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userEmail: data['userEmail'] as String? ?? '',
      deviceToken: data['deviceToken'] as String? ?? '',
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      userProfile: data['userProfile']?.toString(),
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

class UserModel {
  // UserModel class to represent user data
  final String userId;
  final String userName;
  final String userEmail;
  final String deviceToken;
  final bool isEmailVerified;

  UserModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.deviceToken = '',
    this.isEmailVerified = false,
  });

  // Convert UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'deviceToken': deviceToken,
      'isEmailVerified': isEmailVerified,
    };
  }

  // Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      deviceToken: map['deviceToken'] ?? '',
      isEmailVerified: map['isEmailVerified'] ?? false,
    );
  }
}

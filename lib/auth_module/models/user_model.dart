class SocialLoginResponse {
  final bool status;
  final String message;
  final SocialLoginData data;

  SocialLoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SocialLoginResponse.fromJson(Map<String, dynamic> json) {
    return SocialLoginResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: SocialLoginData.fromJson(json['data']),
    );
  }
}

class SocialLoginData {
  final String jwtToken;
  final User user;

  SocialLoginData({
    required this.jwtToken,
    required this.user,
  });

  factory SocialLoginData.fromJson(Map<String, dynamic> json) {
    return SocialLoginData(
      jwtToken: json['jwtToken'] ?? '',
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final int id;
  final String name;
  final String uid;
  final String email;
  final String? phone;
  final String profile;
  final String? fcmToken;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.uid,
    required this.email,
    this.phone,
    required this.profile,
    this.fcmToken,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profile: json['profile'] ?? '',
      fcmToken: json['fcm_token'],
      role: json['role'] ?? '',
    );
  }
}

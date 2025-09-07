import 'package:lingolearn/home_module/models/get_home_language_model.dart';

class UserProfileModel {
  UserProfileModel({
    this.status,
    this.message,
    this.data,
  });

  UserProfileModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? status;
  String? message;
  Data? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class Data {
  String? jwtToken;
  User? user;
  Stats? stats;
  int? lessonsCompleted;
  List<Achievement>? achievements;

  Data({
    this.jwtToken,
    this.user,
    this.stats,
    this.lessonsCompleted,
    this.achievements,
  });

  Data.fromJson(dynamic json) {
    jwtToken = json['jwtToken'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    stats = json['stats'] != null ? Stats.fromJson(json['stats']) : null;
    lessonsCompleted = json['lessonsCompleted'] is int
        ? json['lessonsCompleted']
        : int.tryParse('${json['lessonsCompleted'] ?? 0}');
    if (json['achievements'] != null) {
      achievements = (json['achievements'] as List)
          .map((e) => Achievement.fromJson(e))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['jwtToken'] = jwtToken;
    if (user != null) map['user'] = user!.toJson();
    if (stats != null) map['stats'] = stats!.toJson();
    map['lessonsCompleted'] = lessonsCompleted;
    if (achievements != null) {
      map['achievements'] = achievements!.map((e) => e.toJson()).toList();
    }
    return map;
  }
}

class User {
  num? id;
  String? name;
  String? uid;
  String? email;
  dynamic phone;
  String? password;
  String? loginType;
  dynamic referCode;
  dynamic referredBy;
  String? profile;
  String? fcmToken;
  String? token;
  dynamic otp;
  String? role;
  String? createdAt; // "27 Aug 2025"
  String? updatedAt;

  User({
    this.id,
    this.name,
    this.uid,
    this.email,
    this.phone,
    this.password,
    this.loginType,
    this.referCode,
    this.referredBy,
    this.profile,
    this.fcmToken,
    this.token,
    this.otp,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  User.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    uid = json['uid'];
    email = json['email'];
    phone = json['phone'];
    password = json['password'];
    loginType = json['login_type'];
    referCode = json['refer_code'];
    referredBy = json['referred_by'];
    profile = json['profile'];
    fcmToken = json['fcm_token'];
    token = json['token'];
    otp = json['otp'];
    role = json['role'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['uid'] = uid;
    map['email'] = email;
    map['phone'] = phone;
    map['password'] = password;
    map['login_type'] = loginType;
    map['refer_code'] = referCode;
    map['referred_by'] = referredBy;
    map['profile'] = profile;
    map['fcm_token'] = fcmToken;
    map['token'] = token;
    map['otp'] = otp;
    map['role'] = role;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class Achievement {
  int? id;
  String? title;
  String? description;
  String? iconUrl;
  String? achievedAt;

  Achievement({
    this.id,
    this.title,
    this.description,
    this.iconUrl,
    this.achievedAt,
  });

  Achievement.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    iconUrl = json['icon_url'];
    achievedAt = json['achieved_at'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['icon_url'] = iconUrl;
    map['achieved_at'] = achievedAt;
    return map;
  }
}

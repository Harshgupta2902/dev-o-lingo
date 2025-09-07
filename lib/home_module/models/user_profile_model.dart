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
  Data({
    this.user,
    this.stats,
    this.lessonsCompleted,
    this.achievements,
    this.followers,
    this.following,
    this.notFollowedUsers,
  });

  Data.fromJson(dynamic json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    stats = json['stats'] != null ? Stats.fromJson(json['stats']) : null;
    lessonsCompleted = json['lessonsCompleted'];
    if (json['achievements'] != null) {
      achievements = [];
      json['achievements'].forEach((v) {
        achievements?.add(Achievements.fromJson(v));
      });
    }
    followers = json['followers'];
    following = json['following'];
    if (json['notFollowedUsers'] != null) {
      notFollowedUsers = [];
      json['notFollowedUsers'].forEach((v) {
        notFollowedUsers?.add(NotFollowedUsers.fromJson(v));
      });
    }
  }
  User? user;
  Stats? stats;
  num? lessonsCompleted;
  List<Achievements>? achievements;
  num? followers;
  num? following;
  List<NotFollowedUsers>? notFollowedUsers;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (user != null) {
      map['user'] = user?.toJson();
    }
    if (stats != null) {
      map['stats'] = stats?.toJson();
    }
    map['lessonsCompleted'] = lessonsCompleted;
    if (achievements != null) {
      map['achievements'] = achievements?.map((v) => v.toJson()).toList();
    }
    map['followers'] = followers;
    map['following'] = following;
    if (notFollowedUsers != null) {
      map['notFollowedUsers'] =
          notFollowedUsers?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class NotFollowedUsers {
  NotFollowedUsers({
    this.id,
    this.name,
    this.profile,
  });

  NotFollowedUsers.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    profile = json['profile'];
  }
  num? id;
  String? name;
  String? profile;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['profile'] = profile;
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

class Achievements {
  int? id;
  String? title;
  String? description;
  String? iconUrl;
  String? achievedAt;

  Achievements({
    this.id,
    this.title,
    this.description,
    this.iconUrl,
    this.achievedAt,
  });

  Achievements.fromJson(dynamic json) {
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

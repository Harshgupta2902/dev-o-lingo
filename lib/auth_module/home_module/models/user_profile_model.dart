class UserProfileModel {
  UserProfileModel({
    this.status,
    this.message,
    this.data,});

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
    this.jwtToken,
    this.user,
    this.stats,});

  Data.fromJson(dynamic json) {
    jwtToken = json['jwtToken'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    stats = json['stats'] != null ? Stats.fromJson(json['stats']) : null;
  }
  String? jwtToken;
  User? user;
  Stats? stats;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['jwtToken'] = jwtToken;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    if (stats != null) {
      map['stats'] = stats?.toJson();
    }
    return map;
  }

}

class Stats {
  Stats({
    this.id,
    this.userId,
    this.xp,
    this.streak,
    this.gems,
    this.hearts,
    this.lastHeartUpdate,
    this.lastStreakDate,
    this.createdAt,
    this.updatedAt,});

  Stats.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    xp = json['xp'];
    streak = json['streak'];
    gems = json['gems'];
    hearts = json['hearts'];
    lastHeartUpdate = json['last_heart_update'];
    lastStreakDate = json['last_streak_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  num? userId;
  int? xp;
  num? streak;
  num? gems;
  num? hearts;
  String? lastHeartUpdate;
  String? lastStreakDate;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['xp'] = xp;
    map['streak'] = streak;
    map['gems'] = gems;
    map['hearts'] = hearts;
    map['last_heart_update'] = lastHeartUpdate;
    map['last_streak_date'] = lastStreakDate;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}

class User {
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
    this.updatedAt,});

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
  String? createdAt;
  String? updatedAt;

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
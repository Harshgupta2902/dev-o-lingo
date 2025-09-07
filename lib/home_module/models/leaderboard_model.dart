class LeaderboardModel {
  LeaderboardModel({
      this.status, 
      this.message, 
      this.data,});

  LeaderboardModel.fromJson(dynamic json) {
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
      this.weekly, 
      this.monthly,});

  Data.fromJson(dynamic json) {
    if (json['weekly'] != null) {
      weekly = [];
      json['weekly'].forEach((v) {
        weekly?.add(Weekly.fromJson(v));
      });
    }
    if (json['monthly'] != null) {
      monthly = [];
      json['monthly'].forEach((v) {
        monthly?.add(Monthly.fromJson(v));
      });
    }
  }
  List<Weekly>? weekly;
  List<Monthly>? monthly;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (weekly != null) {
      map['weekly'] = weekly?.map((v) => v.toJson()).toList();
    }
    if (monthly != null) {
      map['monthly'] = monthly?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Monthly {
  Monthly({
      this.rank, 
      this.userId, 
      this.name, 
      this.avatar, 
      this.xp,});

  Monthly.fromJson(dynamic json) {
    rank = json['rank'];
    userId = json['userId'];
    name = json['name'];
    avatar = json['avatar'];
    xp = json['xp'];
  }
  num? rank;
  num? userId;
  String? name;
  String? avatar;
  num? xp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['rank'] = rank;
    map['userId'] = userId;
    map['name'] = name;
    map['avatar'] = avatar;
    map['xp'] = xp;
    return map;
  }

}

class Weekly {
  Weekly({
      this.rank, 
      this.userId, 
      this.name, 
      this.avatar, 
      this.xp,});

  Weekly.fromJson(dynamic json) {
    rank = json['rank'];
    userId = json['userId'];
    name = json['name'];
    avatar = json['avatar'];
    xp = json['xp'];
  }
  num? rank;
  num? userId;
  String? name;
  String? avatar;
  num? xp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['rank'] = rank;
    map['userId'] = userId;
    map['name'] = name;
    map['avatar'] = avatar;
    map['xp'] = xp;
    return map;
  }

}
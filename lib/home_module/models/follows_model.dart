class FollowsModel {
  FollowsModel({
    this.status,
    this.message,
    this.data,
  });

  FollowsModel.fromJson(dynamic json) {
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
    this.total,
    this.items,
  });

  Data.fromJson(dynamic json) {
    total = json['total'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items?.add(Items.fromJson(v));
      });
    }
  }
  num? total;
  List<Items>? items;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total'] = total;
    if (items != null) {
      map['items'] = items?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Items {
  Items({
    this.userId,
    this.name,
    this.avatar,
    this.followedAt,
  });

  Items.fromJson(dynamic json) {
    userId = json['userId'];
    name = json['name'];
    avatar = json['avatar'];
    followedAt = json['followedAt'];
  }
  num? userId;
  String? name;
  String? avatar;
  String? followedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userId'] = userId;
    map['name'] = name;
    map['avatar'] = avatar;
    map['followedAt'] = followedAt;
    return map;
  }
}

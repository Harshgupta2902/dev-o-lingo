class ShopModel {
  ShopModel({
    this.status,
    this.message,
    this.data,
  });

  ShopModel.fromJson(dynamic json) {
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
    this.gems,
    this.hearts,
    this.subscription,
  });

  Data.fromJson(dynamic json) {
    if (json['gems'] != null) {
      gems = [];
      json['gems'].forEach((v) {
        gems?.add(Datas.fromJson(v));
      });
    }
    if (json['hearts'] != null) {
      hearts = [];
      json['hearts'].forEach((v) {
        hearts?.add(Datas.fromJson(v));
      });
    }
    if (json['subscription'] != null) {
      subscription = [];
      json['subscription'].forEach((v) {
        subscription?.add(Datas.fromJson(v));
      });
    }
  }
  List<Datas>? gems;
  List<Datas>? hearts;
  List<Datas>? subscription;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (gems != null) {
      map['gems'] = gems?.map((v) => v.toJson()).toList();
    }
    if (hearts != null) {
      map['hearts'] = hearts?.map((v) => v.toJson()).toList();
    }
    if (subscription != null) {
      map['subscription'] = subscription?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Datas {
  Datas({
    this.id,
    this.sku,
    this.type,
    this.title,
    this.description,
    this.quantity,
    this.priceInr,
    this.currency,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  Datas.fromJson(dynamic json) {
    id = json['id'];
    sku = json['sku'];
    type = json['type'];
    title = json['title'];
    description = json['description'];
    quantity = json['quantity'];
    priceInr = json['price_inr'];
    currency = json['currency'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? sku;
  String? type;
  String? title;
  String? description;
  num? quantity;
  num? priceInr;
  String? currency;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['sku'] = sku;
    map['type'] = type;
    map['title'] = title;
    map['description'] = description;
    map['quantity'] = quantity;
    map['price_inr'] = priceInr;
    map['currency'] = currency;
    map['is_active'] = isActive;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

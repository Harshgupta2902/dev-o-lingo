class GetHomeLanguageModel {
  GetHomeLanguageModel({
    this.status,
    this.message,
    this.data,
  });

  GetHomeLanguageModel.fromJson(dynamic json) {
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
    this.languageId,
    this.languageTitle,
    this.unitCount,
    this.units,
  });

  Data.fromJson(dynamic json) {
    languageId = json['languageId'];
    languageTitle = json['languageTitle'];
    unitCount = json['unitCount'];
    if (json['units'] != null) {
      units = [];
      json['units'].forEach((v) {
        units?.add(Units.fromJson(v));
      });
    }
  }
  num? languageId;
  String? languageTitle;
  num? unitCount;
  List<Units>? units;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['languageId'] = languageId;
    map['languageTitle'] = languageTitle;
    map['unitCount'] = unitCount;
    if (units != null) {
      map['units'] = units?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Units {
  Units({
    this.id,
    this.languageId,
    this.sortOrder,
    this.name,
    this.externalId,
    this.lessonCount,
  });

  Units.fromJson(dynamic json) {
    id = json['id'];
    languageId = json['language_id'];
    sortOrder = json['sort_order'];
    name = json['name'];
    externalId = json['external_id'];
    if (json['lessons'] != null) {
      lessons = [];
      json['lessons'].forEach((v) {
        lessons?.add(Lessons.fromJson(v));
      });
    }
    lessonCount = json['lessonCount'];
  }
  num? id;
  num? languageId;
  num? sortOrder;
  String? name;
  String? externalId;
  List<Lessons>? lessons;
  num? lessonCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['language_id'] = languageId;
    map['sort_order'] = sortOrder;
    map['name'] = name;
    map['external_id'] = externalId;
    if (lessons != null) {
      map['lessons'] = lessons?.map((v) => v.toJson()).toList();
    }
    map['lessonCount'] = lessonCount;
    return map;
  }
}

class Lessons {
  Lessons({
    this.id,
    this.unitId,
    this.name,
    this.externalId,
  });

  Lessons.fromJson(dynamic json) {
    id = json['id'];
    unitId = json['unit_id'];
    name = json['name'];
    externalId = json['external_id'];
  }
  int? id;
  num? unitId;
  String? name;
  String? externalId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['unit_id'] = unitId;
    map['name'] = name;
    map['external_id'] = externalId;
    return map;
  }
}

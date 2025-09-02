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
    this.stats,
    this.languageId,
    this.languageTitle,
    this.unitCount,
    this.lastCompletedLessonId,
    this.units,
  });

  Data.fromJson(dynamic json) {
    stats = json['stats'] != null ? Stats.fromJson(json['stats']) : null;

    languageId = json['languageId'];
    languageTitle = json['languageTitle'];
    unitCount = json['unitCount'];
    lastCompletedLessonId = json['lastCompletedLessonId'];
    if (json['units'] != null) {
      units = [];
      json['units'].forEach((v) {
        units?.add(Units.fromJson(v));
      });
    }
  }
  Stats? stats;
  num? languageId;
  String? languageTitle;
  num? unitCount;
  int? lastCompletedLessonId;
  List<Units>? units;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (stats != null) {
      map['stats'] = stats?.toJson();
    }
    map['languageId'] = languageId;
    map['languageTitle'] = languageTitle;
    map['unitCount'] = unitCount;
    map['lastCompletedLessonId'] = lastCompletedLessonId;
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
    this.isCompleted = false,
    this.isCurrent = false,
  });

  Lessons.fromJson(dynamic json) {
    id = json['id'];
    unitId = json['unit_id'];
    name = json['name'];
    externalId = json['external_id'];
    isCompleted = false;
    isCurrent = false;
  }

  int? id;
  num? unitId;
  String? name;
  String? externalId;
  bool? isCompleted;
  bool? isCurrent;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['unit_id'] = unitId;
    map['name'] = name;
    map['external_id'] = externalId;
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
    this.updatedAt,
  });

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
  num? xp;
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

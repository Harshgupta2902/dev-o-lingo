class ExercisesModel {
  ExercisesModel({
    this.status,
    this.message,
    this.data,});

  ExercisesModel.fromJson(dynamic json) {
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
    this.exercise,
    this.questions,
    this.practicalTasks,});

  Data.fromJson(dynamic json) {
    exercise = json['exercise'] != null ? Exercise.fromJson(json['exercise']) : null;
    if (json['questions'] != null) {
      questions = [];
      json['questions'].forEach((v) {
        questions?.add(Questions.fromJson(v));
      });
    }
    if (json['practical_tasks'] != null) {
      practicalTasks = [];
      json['practical_tasks'].forEach((v) {
        practicalTasks?.add(PracticalTasks.fromJson(v));
      });
    }
  }
  Exercise? exercise;
  List<Questions>? questions;
  List<PracticalTasks>? practicalTasks;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (exercise != null) {
      map['exercise'] = exercise?.toJson();
    }
    if (questions != null) {
      map['questions'] = questions?.map((v) => v.toJson()).toList();
    }
    if (practicalTasks != null) {
      map['practical_tasks'] = practicalTasks?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class PracticalTasks {
  PracticalTasks({
    this.task1,
    this.task2,});

  PracticalTasks.fromJson(dynamic json) {
    task1 = json['task1'];
    task2 = json['task2'];
  }
  String? task1;
  String? task2;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['task1'] = task1;
    map['task2'] = task2;
    return map;
  }

}

class Questions {
  Questions({
    this.id,
    this.languageId,
    this.mapKey,
    this.question,
    this.optionA,
    this.optionB,
    this.optionC,
    this.optionD,
    this.answer,
    this.createdAt,
    this.updatedAt,});

  Questions.fromJson(dynamic json) {
    id = json['id'];
    languageId = json['language_id'];
    mapKey = json['map_key'];
    question = json['question'];
    optionA = json['option_a'];
    optionB = json['option_b'];
    optionC = json['option_c'];
    optionD = json['option_d'];
    answer = json['answer'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  int? id;
  num? languageId;
  String? mapKey;
  String? question;
  String? optionA;
  String? optionB;
  String? optionC;
  String? optionD;
  String? answer;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['language_id'] = languageId;
    map['map_key'] = mapKey;
    map['question'] = question;
    map['option_a'] = optionA;
    map['option_b'] = optionB;
    map['option_c'] = optionC;
    map['option_d'] = optionD;
    map['answer'] = answer;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}

class Exercise {
  Exercise({
    this.id,
    this.slug,
    this.title,
    this.description,
    this.links,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,});

  Exercise.fromJson(dynamic json) {
    id = json['id'];
    slug = json['slug'];
    title = json['title'];
    description = json['description'];
    if (json['links'] != null) {
      links = [];
      json['links'].forEach((v) {
        links?.add(Links.fromJson(v));
      });
    }
    sortOrder = json['sort_order'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? slug;
  String? title;
  String? description;
  List<Links>? links;
  num? sortOrder;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['slug'] = slug;
    map['title'] = title;
    map['description'] = description;
    if (links != null) {
      map['links'] = links?.map((v) => v.toJson()).toList();
    }
    map['sort_order'] = sortOrder;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}

class Links {
  Links({
    this.url,
    this.type,
    this.title,});

  Links.fromJson(dynamic json) {
    url = json['url'];
    type = json['type'];
    title = json['title'];
  }
  String? url;
  String? type;
  String? title;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = url;
    map['type'] = type;
    map['title'] = title;
    return map;
  }

}
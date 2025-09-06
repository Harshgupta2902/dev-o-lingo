class PracticeQuestionsModel {
  PracticeQuestionsModel({
      this.status, 
      this.message, 
      this.data,});

  PracticeQuestionsModel.fromJson(dynamic json) {
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
      this.id, 
      this.userId, 
      this.date, 
      this.status, 
      this.createdAt, 
      this.completedAt, 
      this.earnedXp, 
      this.earnedGems, 
      this.items,});

  Data.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    date = json['date'];
    status = json['status'];
    createdAt = json['created_at'];
    completedAt = json['completed_at'];
    earnedXp = json['earned_xp'];
    earnedGems = json['earned_gems'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items?.add(Items.fromJson(v));
      });
    }
  }
  num? id;
  num? userId;
  String? date;
  String? status;
  String? createdAt;
  dynamic completedAt;
  num? earnedXp;
  num? earnedGems;
  List<Items>? items;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['date'] = date;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['completed_at'] = completedAt;
    map['earned_xp'] = earnedXp;
    map['earned_gems'] = earnedGems;
    if (items != null) {
      map['items'] = items?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Items {
  Items({
      this.id, 
      this.practiceId, 
      this.questionId, 
      this.questionStatus, 
      this.userAnswer, 
      this.isCorrect, 
      this.createdAt, 
      this.question,});

  Items.fromJson(dynamic json) {
    id = json['id'];
    practiceId = json['practice_id'];
    questionId = json['question_id'];
    questionStatus = json['question_status'];
    userAnswer = json['user_answer'];
    isCorrect = json['is_correct'];
    createdAt = json['created_at'];
    question = json['question'] != null ? Question.fromJson(json['question']) : null;
  }
  num? id;
  num? practiceId;
  num? questionId;
  String? questionStatus;
  dynamic userAnswer;
  dynamic isCorrect;
  String? createdAt;
  Question? question;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['practice_id'] = practiceId;
    map['question_id'] = questionId;
    map['question_status'] = questionStatus;
    map['user_answer'] = userAnswer;
    map['is_correct'] = isCorrect;
    map['created_at'] = createdAt;
    if (question != null) {
      map['question'] = question?.toJson();
    }
    return map;
  }

}

class Question {
  Question({
      this.id, 
      this.languageId, 
      this.mapKey, 
      this.title, 
      this.question, 
      this.optionA, 
      this.optionB, 
      this.optionC, 
      this.optionD, 
      this.answer, 
      this.task1, 
      this.task2, 
      this.createdAt, 
      this.updatedAt,});

  Question.fromJson(dynamic json) {
    id = json['id'];
    languageId = json['language_id'];
    mapKey = json['map_key'];
    title = json['title'];
    question = json['question'];
    optionA = json['option_a'];
    optionB = json['option_b'];
    optionC = json['option_c'];
    optionD = json['option_d'];
    answer = json['answer'];
    task1 = json['task1'];
    task2 = json['task2'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  num? languageId;
  String? mapKey;
  String? title;
  String? question;
  String? optionA;
  String? optionB;
  String? optionC;
  String? optionD;
  String? answer;
  String? task1;
  String? task2;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['language_id'] = languageId;
    map['map_key'] = mapKey;
    map['title'] = title;
    map['question'] = question;
    map['option_a'] = optionA;
    map['option_b'] = optionB;
    map['option_c'] = optionC;
    map['option_d'] = optionD;
    map['answer'] = answer;
    map['task1'] = task1;
    map['task2'] = task2;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}
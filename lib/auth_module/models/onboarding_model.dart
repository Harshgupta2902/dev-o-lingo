class OnboardingModel {
  OnboardingModel({
    this.status,
    this.message,
    this.data,
  });

  OnboardingModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
  }
  bool? status;
  String? message;
  List<Data>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Data {
  Data({
    this.id,
    this.qKey,
    this.question,
    this.createdAt,
    this.updatedAt,
    this.onboardingOptions,
  });

  Data.fromJson(dynamic json) {
    id = json['id'];
    qKey = json['q_key'];
    question = json['question'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['onboarding_options'] != null) {
      onboardingOptions = [];
      json['onboarding_options'].forEach((v) {
        onboardingOptions?.add(OnboardingOptions.fromJson(v));
      });
    }
  }
  num? id;
  String? qKey;
  String? question;
  String? createdAt;
  String? updatedAt;
  List<OnboardingOptions>? onboardingOptions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['q_key'] = qKey;
    map['question'] = question;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (onboardingOptions != null) {
      map['onboarding_options'] =
          onboardingOptions?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class OnboardingOptions {
  OnboardingOptions({
    this.id,
    this.questionId,
    this.name,
    this.flag,
    this.color,
  });

  OnboardingOptions.fromJson(dynamic json) {
    id = json['id'];
    questionId = json['question_id'];
    name = json['name'];
    flag = json['flag'];
    color = json['color'];
  }
  num? id;
  num? questionId;
  String? name;
  String? flag;
  String? color;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['question_id'] = questionId;
    map['name'] = name;
    map['flag'] = flag;
    map['color'] = color;
    return map;
  }
}

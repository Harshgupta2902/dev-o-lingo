// models/review_models.dart
class ReviewResponseModel {
  final bool status;
  final String message;
  final List<ReviewItem> data;

  ReviewResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return ReviewResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => ReviewItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReviewItem {
  final int itemId;
  final int practiceId;
  final String practiceDate;
  final String practiceStatus;
  final int questionId;
  final String type;
  final String? userAnswer;
  final ReviewQuestion question;

  ReviewItem({
    required this.itemId,
    required this.practiceId,
    required this.practiceDate,
    required this.practiceStatus,
    required this.questionId,
    required this.type,
    required this.userAnswer,
    required this.question,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      itemId: json['itemId'],
      practiceId: json['practiceId'],
      practiceDate: json['practiceDate'],
      practiceStatus: json['practiceStatus'],
      questionId: json['questionId'],
      type: json['type'],
      userAnswer: json['userAnswer'],
      question: ReviewQuestion.fromJson(json['question'] as Map<String, dynamic>),
    );
  }
}

class ReviewQuestion {
  final int id;
  final int languageId;
  final String mapKey;
  final String title;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String answer;
  final String? task1;
  final String? task2;
  final String createdAt;
  final String updatedAt;

  ReviewQuestion({
    required this.id,
    required this.languageId,
    required this.mapKey,
    required this.title,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.answer,
    this.task1,
    this.task2,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewQuestion.fromJson(Map<String, dynamic> json) {
    return ReviewQuestion(
      id: json['id'],
      languageId: json['language_id'],
      mapKey: json['map_key'],
      title: json['title'],
      question: json['question'],
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionC: json['option_c'],
      optionD: json['option_d'],
      answer: json['answer'],
      task1: json['task1'],
      task2: json['task2'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
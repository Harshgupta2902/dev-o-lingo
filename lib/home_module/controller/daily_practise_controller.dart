import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';

class DailyPractiseController extends GetxController
    with StateMixin<WeekResponse> {
  getDailyPractise() async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.getDailyPractiseTest;
    debugPrint("---------- $apiEndPoint getDailyPractise Start ----------");
    try {
      final response = await getRequest(apiEndPoint: apiEndPoint);

      debugPrint(
          "DailyPractiseController => getDailyPractise > Success $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      final modal = WeekResponse.fromJson(responseData);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getDailyPractise End With Error ----------");
      debugPrint("DailyPractiseController => getDailyPractise > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint getExercisebyId End ----------");
    }
  }
}

class WeekResponse {
  final List<PracticeItem> practices;
  WeekResponse({required this.practices});

  factory WeekResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data']?['practices'] as List? ?? [])
        .map((e) => PracticeItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return WeekResponse(practices: list);
  }
}

class PracticeItem {
  final String date; // "YYYY-MM-DD"
  final bool isToday;
  final String status; // available | locked | completed
  final int? practiceId;
  final int total;
  final int done;
  final int earnedXp;
  final int earnedGems;
  final String? completedAt; // ISO
  final String? completedAtAgo; // "2h", "3d"
  final PracticeSummary summary;

  PracticeItem({
    required this.date,
    required this.isToday,
    required this.status,
    required this.practiceId,
    required this.total,
    required this.done,
    required this.earnedXp,
    required this.earnedGems,
    required this.completedAt,
    required this.completedAtAgo,
    required this.summary,
  });

  factory PracticeItem.fromJson(Map<String, dynamic> j) {
    final s = j['summary'] as Map<String, dynamic>? ?? const {};
    return PracticeItem(
      date: (j['date'] ?? '') as String,
      isToday: (j['isToday'] ?? false) as bool,
      status: (j['status'] ?? '') as String,
      practiceId:
          j['practiceId'] == null ? null : (j['practiceId'] as num).toInt(),
      total: (j['total'] ?? 0) as int,
      done: (j['done'] ?? 0) as int,
      earnedXp: (j['earned_xp'] ?? 0) as int,
      earnedGems: (j['earned_gems'] ?? 0) as int,
      completedAt: j['completed_at'] as String?,
      completedAtAgo: j['completed_at_ago'] as String?,
      summary: PracticeSummary.fromJson(s),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'isToday': isToday,
        'status': status,
        'practiceId': practiceId,
        'total': total,
        'done': done,
        'earned_xp': earnedXp,
        'earned_gems': earnedGems,
        'completed_at': completedAt,
        'completed_at_ago': completedAtAgo,
        'summary': summary.toJson(),
      };
}

class PracticeSummary {
  final int total;
  final int answered;
  final int correct;
  final int wrong;
  final int skipped;

  PracticeSummary({
    required this.total,
    required this.answered,
    required this.correct,
    required this.wrong,
    required this.skipped,
  });

  factory PracticeSummary.fromJson(Map<String, dynamic> j) => PracticeSummary(
        total: (j['total'] ?? 0) as int,
        answered: (j['answered'] ?? 0) as int,
        correct: (j['correct'] ?? 0) as int,
        wrong: (j['wrong'] ?? 0) as int,
        skipped: (j['skipped'] ?? 0) as int,
      );

  Map<String, dynamic> toJson() => {
        'total': total,
        'answered': answered,
        'correct': correct,
        'wrong': wrong,
        'skipped': skipped,
      };
}

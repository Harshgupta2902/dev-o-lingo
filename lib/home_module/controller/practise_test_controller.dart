import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/models/practice_questions_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';

class PracticeSessionController extends GetxController
    with StateMixin<PracticeQuestionsModel> {
  final current = 0.obs;
  final Map<int, String> selected = {};
  final Set<int> skipped = {};
  final elapsedMs = 0.obs;
  bool get isLast => state != null && (state!.data?.items?.length ?? 0) > 0
      ? current.value == state!.data!.items!.length - 1
      : true;

  @override
  void onInit() {
    super.onInit();
    _startTicker();
  }

  getPractiseTest(String id) async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.getPractiseTest;
    debugPrint("---------- $apiEndPoint getPractiseTest Start ----------");
    try {
      final response = await postRequest(
        apiEndPoint: apiEndPoint,
        postData: {"id": id},
      );

      debugPrint(
          "PractiseTestController => getPractiseTest > Success $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      final modal = PracticeQuestionsModel.fromJson(responseData);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getPractiseTest End With Error ----------");
      debugPrint("PractiseTestController => getPractiseTest > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint getExercisebyId End ----------");
    }
  }

  void _startTicker() async {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (isClosed) return false;
      elapsedMs.value += 1000;
      return true;
    });
  }

  void selectOption(Items it, String optionText) {
    final qid = it.questionId?.toInt() ?? 0;
    if (qid == 0) return;
    selected[qid] = optionText;
    skipped.remove(qid);
    update(['options']);
  }

  void markSkipped(Items it) {
    final qid = it.questionId?.toInt() ?? 0;
    if (qid == 0) return;
    skipped.add(qid);
    selected.remove(qid);
    update(['options']);
  }

  void next() {
    final total = state?.data?.items?.length ?? 0;
    if (total == 0) return;
    if (current.value < total - 1) current.value += 1;
    update();
  }

  void previous() {
    if (current.value > 0) current.value -= 1;
  }

  Future<dynamic> submit() async {
    if (state == null || state!.data == null) throw Exception('No state');

    final items = state!.data!.items ?? [];
    final practiceId = state!.data!.id;

    final payload = <String, dynamic>{
      "practiceId": practiceId,
      "answers": <String, dynamic>{}
    };

    for (final it in items) {
      final qid = it.questionId?.toInt() ?? 0;
      if (qid == 0) continue;

      if (selected.containsKey(qid)) {
        payload["answers"]["$qid"] = {
          "status": "answered",
          "answer": selected[qid],
        };
      } else if (skipped.contains(qid)) {
        payload["answers"]["$qid"] = {
          "status": "skipped",
        };
      } else {
        payload["answers"]["$qid"] = {
          "status": "skipped",
        };
      }
    }

    // use your Dio request util (keep consistent with your project)
    final resp = await postRequest(
      apiEndPoint: APIEndPoints.submitDailyPractice,
      postData: payload,
    );
    // if your postRequest returns a Dio Response:
    final data = resp.data is String ? jsonDecode(resp.data) : resp.data;
    if (data is Map && data['status'] == true) return data;
    throw Exception('Submit failed: $data');
  }
}

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lingolearn/auth_module/models/onboarding_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OnboardingController extends GetxController
    with StateMixin<OnboardingModel> {
  RxList<Map<String, dynamic>> questions = <Map<String, dynamic>>[].obs;
  final Map<String, String> answers = {};

  void setAnswer(String key, String value) {
    answers[key] = value;
  }

  fetchQuestions() async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.getOnboardingQuestions;
    debugPrint(
        "---------- $apiEndPoint getOnboardingQuestions Start ----------");
    try {
      final response = await getRequest(apiEndPoint: apiEndPoint);

      debugPrint(
          "OnboardingController => getOnboardingQuestions > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;
      final modal = OnboardingModel.fromJson(responseData);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getOnboardingQuestions End With Error ----------");
      debugPrint(
          "OnboardingController => getOnboardingQuestions > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint(
          "---------- $apiEndPoint getOnboardingQuestions End ----------");
    }
  }

  Future<Map<String, dynamic>> getAllOnboardingData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String buildNumber = packageInfo.buildNumber;
    String buildSignature = packageInfo.buildSignature;
    String version = packageInfo.version;

    return {
      'questionnaire': {...answers},
      'metadata': {
        'completedAt': DateTime.now().toIso8601String(),
        'buildNo': buildNumber,
        'buildSignature': buildSignature,
        'version': version,
      }
    };
  }

  void resetAllData() {
    answers.clear();
  }
}

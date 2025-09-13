import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/home_module/models/review_models.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';

class PractiseCenterController extends GetxController
    with StateMixin<ReviewResponseModel> {
  final RxBool isPremium = false.obs;

  @override
  void onInit() {
    super.onInit();
    getWrongQuestions();
  }

  getWrongQuestions() async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.reviewWrongQuestions;
    debugPrint("---------- $apiEndPoint getWrongQuestions Start ----------");
    try {
      final response = await getRequest(apiEndPoint: apiEndPoint);

      debugPrint(
          "PractiseCenterController => getWrongQuestions > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      final modal = ReviewResponseModel.fromJson(responseData);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getWrongQuestions End With Error ----------");
      debugPrint(
          "PractiseCenterController => getWrongQuestions > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint getWrongQuestions End ----------");
    }
  }

  void togglePremium() {
    isPremium.value = !isPremium.value;
  }
}

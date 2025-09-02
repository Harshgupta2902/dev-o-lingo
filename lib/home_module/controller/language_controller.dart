import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/home_module/models/get_home_language_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';

class LanguageController extends GetxController
    with StateMixin<GetHomeLanguageModel> {
  getLanguageData() async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.getLanguageData;
    debugPrint("---------- $apiEndPoint getLanguageData Start ----------");
    try {
      final response = await postRequest(
          apiEndPoint: apiEndPoint, postData: {"email": getEmailId()});

      debugPrint("LanguageController => getLanguageData > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      final modal = GetHomeLanguageModel.fromJson(responseData);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getLanguageData End With Error ----------");
      debugPrint("LanguageController => getLanguageData > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint getLanguageData End ----------");
    }
  }
}

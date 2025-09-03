import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/home_module/models/get_home_language_model.dart';
import 'package:lingolearn/home_module/models/user_profile_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';

class UserStatsController extends GetxController with StateMixin<Stats> {
  getUserStats() async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.getUserStats;
    debugPrint("---------- $apiEndPoint getUserStats Start ----------");
    try {
      final response = await getRequest(apiEndPoint: apiEndPoint);

      debugPrint("UserStatsController => getUserStats > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      final modal = Stats.fromJson(responseData['data']);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getUserStats End With Error ----------");
      debugPrint("UserStatsController => getUserStats > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint getUserStats End ----------");
    }
  }
}

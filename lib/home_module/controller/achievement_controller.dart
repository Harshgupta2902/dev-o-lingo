import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/home_module/models/user_profile_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';

class AchievementController extends GetxController
    with StateMixin<List<Achievements>> {
  
  static AchievementController get to => Get.find();

  getAllAchievements() async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.getAchievements;
    debugPrint("---------- $apiEndPoint getAchievements Start ----------");
    try {
      final response = await getRequest(apiEndPoint: apiEndPoint);

      debugPrint("AchievementController => getAllAchievements > Success $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (responseData['status'] == true && responseData['data'] != null) {
        final List<Achievements> achievements = [];
        responseData['data'].forEach((v) {
          achievements.add(Achievements.fromJson(v));
        });
        change(achievements, status: RxStatus.success());
      } else {
        change([], status: RxStatus.success());
      }
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getAchievements End With Error ----------");
      debugPrint("AchievementController => getAchievements > Error $error ");
      change(null, status: RxStatus.error(error.toString()));
    } finally {
      debugPrint("---------- $apiEndPoint getAchievements End ----------");
    }
  }
}

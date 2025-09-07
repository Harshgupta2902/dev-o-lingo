import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/home_module/models/leaderboard_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';

class LeaderboardController extends GetxController
    with StateMixin<LeaderboardModel> {
  getLeaderboard() async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.getLeaderboard;
    debugPrint("---------- $apiEndPoint getLeaderboard Start ----------");
    try {
      final response = await getRequest(apiEndPoint: apiEndPoint);

      debugPrint(
          "LeaderboardController => getLeaderboard > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      final modal = LeaderboardModel.fromJson(responseData);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getLeaderboard End With Error ----------");
      debugPrint("LeaderboardController => getLeaderboard > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint getLeaderboard End ----------");
    }
  }
}

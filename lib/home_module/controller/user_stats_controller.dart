import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/home_module/models/get_home_language_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';
import 'package:lingolearn/utilities/constants/storage_keys.dart';
import 'package:lingolearn/home_module/controller/app_controller.dart';

class UserStatsController extends GetxController with StateMixin<Stats> {
  @override
  void onInit() {
    super.onInit();
    _loadCachedData();
  }

  _loadCachedData() {
    final cachedData = prefs.read(StorageKeys.userStatsCache);
    if (cachedData != null) {
      try {
        final modal =
            Stats.fromJson(cachedData is String ? jsonDecode(cachedData) : cachedData);
        change(modal, status: RxStatus.success());
      } catch (e) {
        debugPrint("Error loading cached user stats: $e");
      }
    }
  }

  Future<void> getUserStats() async {
    // If we don't have cached data, show loading
    if (state == null) {
      change(null, status: RxStatus.loading());
    }

    const apiEndPoint = APIEndPoints.getUserStats;
    debugPrint("---------- $apiEndPoint getUserStats Start ----------");
    try {
      final response = await getRequest(apiEndPoint: apiEndPoint);

      debugPrint("UserStatsController => getUserStats > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      // Cache the response data
      prefs.write(StorageKeys.userStatsCache, responseData['data']);
      
      // Update global online status
      Get.find<AppController>().isOnline.value = true;

      final modal = Stats.fromJson(responseData['data']);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getUserStats End With Error ----------");
      debugPrint("UserStatsController => getUserStats > Error $error ");

      // Update global online status (don't force false here if language sync succeeded,
      // but AppController handles this parallelism anyway)
      
      if (state == null) {
        change(null, status: RxStatus.error(error.toString()));
      }
    } finally {
      debugPrint("---------- $apiEndPoint getUserStats End ----------");
    }
  }
}


import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/home_module/models/get_home_language_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';
import 'package:lingolearn/home_module/controller/app_controller.dart';
import 'package:lingolearn/utilities/constants/storage_keys.dart';

class LanguageController extends GetxController
    with StateMixin<GetHomeLanguageModel> {
  final isCached = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedData();
  }

  _loadCachedData() {
    final cachedData = prefs.read(StorageKeys.languageDataCache);
    if (cachedData != null) {
      try {
        final modal = GetHomeLanguageModel.fromJson(
            cachedData is String ? jsonDecode(cachedData) : cachedData);
        isCached.value = true;
        change(modal, status: RxStatus.success());
      } catch (e) {
        debugPrint("Error loading cached language data: $e");
      }
    }
  }

  Future<void> getLanguageData() async {
    // If we don't have cached data, show loading
    if (state == null) {
      change(null, status: RxStatus.loading());
    }

    const apiEndPoint = APIEndPoints.getLanguageData;
    debugPrint("---------- $apiEndPoint getLanguageData Start ----------");
    try {
      final response = await postRequest(
        apiEndPoint: apiEndPoint,
        postData: {"email": getEmailId()},
      );

      debugPrint("LanguageController => getLanguageData > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      // Cache the response
      prefs.write(StorageKeys.languageDataCache, responseData);
      isCached.value = false;
      
      // Update global online status
      Get.find<AppController>().isOnline.value = true;

      final modal = GetHomeLanguageModel.fromJson(responseData);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getLanguageData End With Error ----------");
      debugPrint("LanguageController => getLanguageData > Error $error ");

      // Update global online status
      Get.find<AppController>().isOnline.value = false;

      if (state == null) {
        change(null, status: RxStatus.error(error.toString()));
      } else {
        // If we already have data (from cache), showing offline indicator is enough
        // LanguageController.to or similar could be used but we used Get.find earlier
      }
    } finally {
      debugPrint("---------- $apiEndPoint getLanguageData End ----------");
    }
  }
}


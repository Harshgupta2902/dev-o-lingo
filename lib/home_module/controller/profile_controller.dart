import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/home_module/models/user_profile_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';

class ProfileController extends GetxController
    with StateMixin<UserProfileModel> {
  getUserProfile() async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.getUserProfile;
    debugPrint("---------- $apiEndPoint getUserProfile Start ----------");
    try {
      final response = await postRequest(
          apiEndPoint: apiEndPoint, postData: {"email": getEmailId()});

      debugPrint("ProfileController => getUserProfile > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      final modal = UserProfileModel.fromJson(responseData);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getUserProfile End With Error ----------");
      debugPrint("ProfileController => getUserProfile > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint getUserProfile End ----------");
    }
  }
}




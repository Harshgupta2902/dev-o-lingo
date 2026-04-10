import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/home_module/models/public_user_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';

class OtherUserProfileController extends GetxController with StateMixin<PublicUserModel> {
  final int userId;
  OtherUserProfileController(this.userId);

  @override
  void onInit() {
    super.onInit();
    getPublicProfile();
  }

  Future<void> getPublicProfile() async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.getPublicUserStats;
    try {
      final response = await getRequest(
        apiEndPoint: apiEndPoint,
        queryParameters: {"userId": userId},
      );

      final responseData = response.data is String ? jsonDecode(response.data) : response.data;
      final modal = PublicUserModel.fromJson(responseData);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint("OtherUserProfileController => Error $error ");
      change(null, status: RxStatus.error(error.toString()));
    }
  }

  Future<bool> followUser() async {
    try {
      final response = await postRequest(
        apiEndPoint: APIEndPoints.follow,
        postData: {"targetUserId": userId},
      );
      if (response.statusCode == 200) {
        await getPublicProfile();
        return true;
      }
    } catch (e) {
      debugPrint("Follow error: $e");
    }
    return false;
  }

  Future<bool> unfollowUser() async {
    try {
      final response = await postRequest(
        apiEndPoint: APIEndPoints.unfollow,
        postData: {"targetUserId": userId},
      );
      if (response.statusCode == 200) {
        await getPublicProfile();
        return true;
      }
    } catch (e) {
      debugPrint("Unfollow error: $e");
    }
    return false;
  }

  Future<bool> blockUser() async {
    try {
      final response = await postRequest(
        apiEndPoint: APIEndPoints.blockUser,
        postData: {"targetUserId": userId},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Block error: $e");
    }
    return false;
  }

  Future<bool> reportUser(String reason) async {
    try {
      final response = await postRequest(
        apiEndPoint: APIEndPoints.reportUser,
        postData: {"targetUserId": userId, "reason": reason},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Report error: $e");
    }
    return false;
  }
}

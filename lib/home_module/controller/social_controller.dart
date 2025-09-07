import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/home_module/models/follows_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';

class SocialController extends GetxController with StateMixin<FollowsModel> {
  Future<dynamic> followUser(String id) async {
    const apiEndPoint = APIEndPoints.follow;
    debugPrint("---------- $apiEndPoint followUser Start ----------");
    try {
      final response = await postRequest(
        apiEndPoint: apiEndPoint,
        postData: {"targetUserId": id},
      );

      debugPrint("SocialController => followUser > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      return responseData;
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint followUser End With Error ----------");
      debugPrint("SocialController => followUser > Error $error ");
    } finally {
      debugPrint("---------- $apiEndPoint followUser End ----------");
    }
  }

  Future<dynamic> unfollowUser(String id) async {
    const apiEndPoint = APIEndPoints.unfollow;
    debugPrint("---------- $apiEndPoint unfollowUser Start ----------");
    try {
      final response = await postRequest(
        apiEndPoint: apiEndPoint,
        postData: {"targetUserId": id},
      );

      debugPrint("SocialController => unfollowUser > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      return responseData;
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint unfollowUser End With Error ----------");
      debugPrint("SocialController => unfollowUser > Error $error ");
    } finally {
      debugPrint("---------- $apiEndPoint unfollowUser End ----------");
    }
  }

  getFollowers() async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.followers;
    debugPrint("---------- $apiEndPoint getFollowers Start ----------");
    try {
      final response = await getRequest(apiEndPoint: apiEndPoint);

      debugPrint("ProfileController => getFollowers > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      final modal = FollowsModel.fromJson(responseData);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getFollowers End With Error ----------");
      debugPrint("ProfileController => getFollowers > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint getFollowers End ----------");
    }
  }

  getFollowing() async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.following;
    debugPrint("---------- $apiEndPoint getFollowing Start ----------");
    try {
      final response = await getRequest(apiEndPoint: apiEndPoint);

      debugPrint("ProfileController => getFollowing > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      final modal = FollowsModel.fromJson(responseData);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getFollowing End With Error ----------");
      debugPrint("ProfileController => getFollowing > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint getFollowing End ----------");
    }
  }
}

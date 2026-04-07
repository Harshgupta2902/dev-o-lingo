import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/home_module/controller/user_stats_controller.dart';
import 'package:lingolearn/home_module/models/notification_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';

class NotificationController extends GetxController
    with StateMixin<NotificationData> {
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getNotifications();
  }

  Future<void> getNotifications() async {
    const apiEndPoint = APIEndPoints.getNotifications;
    try {
      final response = await getRequest(apiEndPoint: apiEndPoint);
      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      final result = NotificationResponse.fromJson(responseData);
      if (result.status == true && result.data != null) {
        unreadCount.value = result.data?.unreadCount ?? 0;
        change(result.data, status: RxStatus.success());
      } else {
        change(null, status: RxStatus.error(result.message));
      }
    } catch (error) {
      debugPrint("NotificationController => getNotifications > Error $error ");
      change(null, status: RxStatus.error(error.toString()));
    }
  }

  Future<void> markAllAsRead() async {
    const apiEndPoint = APIEndPoints.markAllNotificationsRead;
    try {
      await postRequest(apiEndPoint: apiEndPoint, postData: {});
      getNotifications();
      // Also refresh user stats to update dashboard badge count
      if (Get.isRegistered<UserStatsController>()) {
        Get.find<UserStatsController>().getUserStats();
      }
    } catch (error) {
      debugPrint("NotificationController => markAllAsRead > Error $error ");
    }
  }
}

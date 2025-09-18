import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/home_module/models/shop/shop_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';

class ShopController extends GetxController with StateMixin<ShopModel> {
  getShopItems() async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.getShopItems;
    debugPrint("---------- $apiEndPoint getShopItems Start ----------");
    try {
      final response = await getRequest(apiEndPoint: apiEndPoint);

      debugPrint("ShopController => getShopItems > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      final modal = ShopModel.fromJson(responseData);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getShopItems End With Error ----------");
      debugPrint("ShopController => getShopItems > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint getShopItems End ----------");
    }
  }
}

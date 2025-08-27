import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lingolearn/auth_module/home_module/models/exercises_model.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';

class ExercisesController extends GetxController
    with StateMixin<ExercisesModel> {
  getExercisebyId(String externaId) async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.getExercisesbyId;
    debugPrint("---------- $apiEndPoint getExercisebyId Start ----------");
    try {
      final response = await postRequest(
          apiEndPoint: apiEndPoint, postData: {"external_id": externaId});

      debugPrint("ExercisesController => getExercisebyId > Success  $response");

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      final modal = ExercisesModel.fromJson(responseData);
      change(modal, status: RxStatus.success());
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint getExercisebyId End With Error ----------");
      debugPrint("ExercisesController => getExercisebyId > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint getExercisebyId End ----------");
    }
  }
}

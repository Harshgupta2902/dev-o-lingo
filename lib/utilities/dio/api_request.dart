import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'api_client.dart';

Future<Response> getRequest({required String apiEndPoint}) async {
  Dio client = NewClient().init();
  debugPrint("🌐 GET → $apiEndPoint [START]");

  try {
    final response = await client.get(apiEndPoint);
    debugPrint("✅ GET ← $apiEndPoint [END] "
        "Status: ${response.statusCode}");
    return response;
  } on DioException catch (e) {
    if (e.response != null) {
      debugPrint("❌ GET ERROR ${e.response?.statusCode} @ $apiEndPoint");
      debugPrint("   ↳ Response: ${e.response?.data}");
    } else {
      debugPrint("❌ GET ERROR @ $apiEndPoint → ${e.message}");
    }
    rethrow;
  } catch (e) {
    debugPrint("❌ GET Unexpected error @ $apiEndPoint → $e");
    rethrow;
  }
}

Future<Response> postRequest({
  required String apiEndPoint,
  required Map<String, dynamic> postData,
}) async {
  Dio client = NewClient().init();
  debugPrint("🌐 POST → $apiEndPoint [START]");
  debugPrint("   ↳ Payload: $postData");

  try {
    final response = await client.post(apiEndPoint, data: postData);
    debugPrint("✅ POST ← $apiEndPoint [END] "
        "Status: ${response.statusCode}");
    return response;
  } on DioException catch (e) {
    if (e.response != null) {
      debugPrint("❌ POST ERROR ${e.response?.statusCode} @ $apiEndPoint");
      debugPrint("   ↳ Response: ${e.response?.data}");
    } else {
      debugPrint("❌ POST ERROR @ $apiEndPoint → ${e.message}");
    }
    rethrow;
  } catch (e) {
    debugPrint("❌ POST Unexpected error @ $apiEndPoint → $e");
    rethrow;
  }
}

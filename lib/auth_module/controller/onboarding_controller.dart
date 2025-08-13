import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OnboardingController extends GetxController {
  RxList<Map<String, dynamic>> questions = <Map<String, dynamic>>[].obs;
  RxBool isLoading = true.obs;
  final Map<String, String> answers = {};
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void setAnswer(String key, String value) {
    answers[key] = value;
  }

  Future<void> fetchQuestions() async {
    try {
      isLoading(true);
      final doc = await _db.collection('onboarding').doc('questions').get();
      if (doc.exists) {
        final data = doc.data();
        final fetchedQuestions =
            List<Map<String, dynamic>>.from(data?['questions'] ?? []);
        questions.assignAll(fetchedQuestions);
      }
    } catch (e) {
      debugPrint('Error fetching onboarding questions: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> getAllOnboardingData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String buildNumber = packageInfo.buildNumber;
    String buildSignature = packageInfo.buildSignature;
    String version = packageInfo.version;

    return {
      'questionnaire': {...answers},
      'metadata': {
        'completedAt': FieldValue.serverTimestamp(),
        'buildNo': buildNumber,
        'buildSignature': buildSignature,
        'version': version,
      }
    };
  }

  void resetAllData() {
    answers.clear();
  }
}

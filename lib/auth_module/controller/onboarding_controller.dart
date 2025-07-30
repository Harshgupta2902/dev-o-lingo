import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OnboardingController extends GetxController {
  String? learningLanguage;
  String? discoverySource;
  String? proficiency;
  String? motivation;
  String? studyTarget;

  void setAnswer(String key, String value) {
    debugPrint("✅ setAnswer called: $key = $value");
    switch (key) {
      case 'learningLanguage':
        learningLanguage = value;
        break;
      case 'discoverySource':
        discoverySource = value;
        break;
      case 'proficiency':
        proficiency = value;
        break;
      case 'motivation':
        motivation = value;
        break;
      case 'studyTarget':
        studyTarget = value;
        break;
    }
  }

  // Enhanced method to get all data as Map for Firebase
  Future<Map<String, dynamic>> getAllOnboardingData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String buildNumber = packageInfo.buildNumber;
    String buildSignature = packageInfo.buildSignature;
    String version = packageInfo.version;

    return {
      'questionnaire': {
        'learningLanguage': learningLanguage,
        'discoverySource': discoverySource,
        'proficiency': proficiency,
        'motivation': motivation,
        'studyTarget': studyTarget,
      },
      'metadata': {
        'completedAt': FieldValue.serverTimestamp(),
        'buildNo': buildNumber,
        'buildSignature': buildSignature,
        'version': version,
      }
    };
  }

  // Method to reset all data (useful for testing)
  void resetAllData() {
    learningLanguage = null;
    discoverySource = null;
    proficiency = null;
    motivation = null;
    studyTarget = null;
    debugPrint("🔄 All onboarding data has been reset");
  }
}

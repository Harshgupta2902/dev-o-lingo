import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/language_controller.dart';
import 'package:lingolearn/home_module/controller/user_stats_controller.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';

class AppController extends GetxController {
  static AppController get to => Get.find();

  final isOnline = true.obs;
  final isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initial sync on app start
    if (isLoggedIn()) {
      refreshAllData(showLoading: false);
    }
  }

  /// Refreshes all global data from the API
  Future<void> refreshAllData({bool showLoading = true}) async {
    if (isSyncing.value) return;

    try {
      isSyncing.value = showLoading;
      
      // Get references to controllers
      final languageController = Get.find<LanguageController>();
      final userStatsController = Get.find<UserStatsController>();

      // Run syncs in parallel
      await Future.wait<void>([
        languageController.getLanguageData(),
        userStatsController.getUserStats(),
      ]);

      // If we got here, we are likely online
      isOnline.value = true;
    } catch (e) {
      debugPrint("Global Sync Error: $e");
      isOnline.value = false;
    } finally {
      isSyncing.value = false;
    }
  }

  /// A helper function to check connection before performing an action
  /// If offline, it shows a premium bottom sheet and returns false
  bool performActionWithConnection(BuildContext context, {required String actionName}) {
    if (!isOnline.value) {
      showOfflineBottomSheet(context, actionName: actionName);
      return false;
    }
    return true;
  }

  void showOfflineBottomSheet(BuildContext context, {required String actionName}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.orange,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Connection Required",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "You need to be online to $actionName. Please check your internet connection and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  refreshAllData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02), // Duolingo green
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "RETRY",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "LATER",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

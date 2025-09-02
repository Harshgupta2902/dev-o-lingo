import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/language_controller.dart';
import 'package:lingolearn/home_module/controller/profile_controller.dart';
import 'package:lingolearn/home_module/view/bottom_navigation.dart';

final languageController = Get.put(LanguageController());
final profileController = Get.put(ProfileController());

class LandingView extends StatefulWidget {
  const LandingView({super.key, required this.child});
  final Widget child;

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  @override
  void initState() {
    super.initState();
    _initData(); // ✅ call async loader
  }

  Future<void> _initData() async {
    await languageController.getLanguageData();
    profileController.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

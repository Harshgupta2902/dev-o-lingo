import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lingolearn/auth_module/components/polygon_text.dart';
import 'package:lingolearn/auth_module/controller/auth_controller.dart';
import 'package:lingolearn/auth_module/controller/onboarding_controller.dart';
import 'package:lingolearn/utilities/constants/assets_path.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';
import 'package:lingolearn/utilities/theme/core_box_shadow.dart';

final onBoardingController = Get.put(OnboardingController());

final authController = Get.put(AuthController());

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  void initState() {
    onBoardingController.fetchQuestions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const PolygonTextBox(
                  title: "Hi there! I’m El!",
                  direction: TriangleDirection.bottom,
                  offset: 70,
                  borderRadius: 14,
                ),
                const SizedBox(height: 20),

                /// 👋 Emoji or SVG
                SvgPicture.asset(
                  AssetPath.hiImg,
                  height: 180,
                ),
                const SizedBox(height: kToolbarHeight),

                /// 📝 App Name & Tagline
                const Text(
                  'Lingo Learn',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Learn coding languages whenever and\nwherever you want. It\'s free and forever.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              boxShadow: AppBoxShadow.mainButtonShadow,
              borderRadius: BorderRadius.circular(25),
            ),
            child: ElevatedButton(
              onPressed: () async {
                await authController.googleSignIn(isRegister: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C4AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text("GET STARTED"),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () async {
              await authController.googleSignIn(isRegister: false);
              MyNavigator.popUntilAndPushNamed(GoPaths.dashboardView);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6C4AFF),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              "I ALREADY HAVE AN ACCOUNT",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lingolearn/auth_module/components/polygon_text.dart';
import 'package:lingolearn/auth_module/controller/auth_controller.dart';
import 'package:lingolearn/auth_module/controller/onboarding_controller.dart';
import 'package:lingolearn/utilities/constants/assets_path.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

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

  Future<void> _handleGoogleAuth() async {
    await authController.googleSignIn();
    await authController.isLoggingIn.stream.firstWhere((v) => v == false);
    if (Get.currentRoute == GoPaths.onBoardingView) return;
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
      backgroundColor: kBeigeBg,
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
                  borderRadius: 24,
                ),
                const SizedBox(height: 32),

                /// 👋 Emoji or SVG
                SvgPicture.asset(
                  AssetPath.hiImg,
                  height: 160,
                ),
                const SizedBox(height: 48),

                /// 📝 App Name & Tagline
                const Text(
                  'Lingo Learn',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: kOnSurface,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Learn coding languages whenever and wherever you want. It\'s free and forever.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: kMuted,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: kDarkSlate.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  await _handleGoogleAuth();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDarkSlate,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "GET STARTED",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await _handleGoogleAuth();
              },
              style: TextButton.styleFrom(
                foregroundColor: kMuted,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "I ALREADY HAVE AN ACCOUNT",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

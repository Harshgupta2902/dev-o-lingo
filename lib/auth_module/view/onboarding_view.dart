// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lingolearn/auth_module/components/polygon_text.dart';
import 'package:lingolearn/auth_module/controller/auth_controller.dart';
import 'package:lingolearn/auth_module/controller/onboarding_controller.dart';
import 'package:lingolearn/auth_module/models/onboarding_model.dart';
import 'package:lingolearn/utilities/common/scaffold_messenger.dart';
import 'package:lingolearn/utilities/common/secondary_header.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

final onBoardingController = Get.put(OnboardingController());
final authController = Get.put(AuthController());

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView>
    with TickerProviderStateMixin {
  int currentPage = 0;
  String? selectedOption;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    onBoardingController.fetchQuestions();
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _resetAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _scaleController.reset();
    _startAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeigeBg,
      body: onBoardingController.obx(
        (onboardingModel) {
          final questions = onboardingModel?.data ?? [];

          if (currentPage < questions.length) {
            final q = questions[currentPage];
            return _buildQuestionPage(
              context,
              onBoardingController,
              q.question ?? "",
              q.onboardingOptions ?? [],
              q.qKey ?? "",
            );
          } else {
            return _buildSuccessPage();
          }
        },
        onLoading: const Center(child: CircularProgressIndicator()),
        onError: (error) =>
            Center(child: Text(error ?? "Something went wrong")),
      ),
    );
  }

  Widget _buildQuestionPage(
    BuildContext context,
    OnboardingController controller,
    String title,
    List<OnboardingOptions> options,
    String key,
  ) {
    return Scaffold(
      backgroundColor: kBeigeBg,
      body: Column(
        children: [
          SecondaryHeader(
            onBackTap: () {
              if (currentPage > 0) {
                setState(() {
                  currentPage--;
                  selectedOption = null;
                });
                _resetAnimations();
              } else {
                MyNavigator.pop();
              }
            },
            customTitle: Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                border: Border.all(color: kSandyBorder, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: (currentPage + 1) /
                      (onboardingController.questions.length + 4),
                  backgroundColor: kBeigeBg,
                  valueColor: const AlwaysStoppedAnimation<Color>(kPrimary),
                ),
              ),
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      ScaleTransition(
                  scale: _scaleAnimation,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/emojis/hi.svg',
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PolygonTextBox(
                          title: title,
                          direction: TriangleDirection.left,
                          offset: 28,
                          borderRadius: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selectedOption == option.name;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      curve: Curves.elasticOut,
                      margin: const EdgeInsets.only(bottom: 16),
                      transform: Matrix4.translationValues(
                        isSelected ? 8 : 0,
                        0,
                        0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            selectedOption = option.name;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 18),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected
                                  ? kPrimary
                                  : kSandyBorder,
                              width: isSelected ? 3 : 1.5,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: kPrimary.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              )
                            ] : [],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(option.color!))
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    option.flag!,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option.name!,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: kOnSurface,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: const BoxDecoration(
                                    color: kPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: kDarkSlate,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        color: Colors.transparent,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: selectedOption != null ? [
              BoxShadow(
                color: kDarkSlate.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ] : [],
          ),
          child: ElevatedButton(
            onPressed: selectedOption != null
                ? () {
                    HapticFeedback.mediumImpact();
                    controller.setAnswer(key, selectedOption!);
                    setState(() {
                      currentPage++;
                      selectedOption = null;
                    });
                    _resetAnimations();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: kDarkSlate,
              disabledBackgroundColor: kMuted.withOpacity(0.2),
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              foregroundColor: Colors.white,
            ),
            child: Text(
              "CONTINUE",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: selectedOption != null
                    ? Colors.white
                    : kMuted.withOpacity(0.5),
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessPage() {
    return Scaffold(
      backgroundColor: kBeigeBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PolygonTextBox(
                title: "Awesome!",
                offset: 50,
                direction: TriangleDirection.bottom,
                borderRadius: 24,
              ),
              const SizedBox(height: 48),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: kSandyBorder, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: kDarkSlate.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🎉',
                      style: TextStyle(fontSize: 64),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              SlideTransition(
                position: _slideAnimation,
                child: const Text(
                  "Welcome to DevLingo!",
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: kOnSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SlideTransition(
                position: _slideAnimation,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        "Your coding journey starts now",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: kMuted,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Let's create your profile and track progress!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: kMuted,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                  final googleUser = await authController.signInSilently();
                  final userId = await authController.fetchUserData(googleUser);

                  final response =
                      await authController.submitOnboarding(userId.toString());
                  if (response['status'] == true) {
                    MyNavigator.pushNamed(GoPaths.dashboardView);
                  } else {
                    messageScaffold(content: response['message'] ?? "Something went wrong");
                  }
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
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lingolearn/auth_module/components/polygon_text.dart';
import 'package:lingolearn/auth_module/controller/auth_controller.dart';
import 'package:lingolearn/auth_module/controller/onboarding_controller.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';
import 'package:lingolearn/utilities/theme/core_box_shadow.dart';

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

  final List<Map<String, dynamic>> questions = const [
    {
      "key": "learningLanguage",
      "question": "Which programming language would you like to learn?",
      "options": [
        {"name": "JavaScript", "flag": "🟨", "color": 0xFFF7DF1E},
        {"name": "Python", "flag": "🐍", "color": 0xFF3776AB},
        {"name": "C++", "flag": "💻", "color": 0xFF00599C},
        {"name": "Java", "flag": "☕️", "color": 0xFFED8B00},
        {"name": "Go", "flag": "🐹", "color": 0xFF00ADD8},
        {"name": "Rust", "flag": "🦀", "color": 0xFF000000}
      ]
    },
    {
      "key": "discoverySource",
      "question": "How did you discover DevLingo?",
      "options": [
        {"name": "GitHub", "flag": "🐙", "color": 0xFF181717},
        {"name": "Twitter", "flag": "🐦", "color": 0xFF1DA1F2},
        {"name": "Reddit", "flag": "👽", "color": 0xFFFF4500},
        {"name": "Friend", "flag": "🤝", "color": 0xFF4CAF50},
        {"name": "Google", "flag": "🔍", "color": 0xFF4285F4}
      ]
    },
    {
      "key": "proficiency",
      "question": "What's your current experience level?",
      "options": [
        {"name": "Total beginner", "flag": "🌱", "color": 0xFF8BC34A},
        {"name": "Basic syntax", "flag": "🧩", "color": 0xFF2196F3},
        {"name": "Can build small apps", "flag": "🔧", "color": 0xFFFF9800},
        {"name": "Intermediate+", "flag": "🚀", "color": 0xFF9C27B0}
      ]
    },
    {
      "key": "motivation",
      "question": "Why do you want to learn coding?",
      "options": [
        {"name": "For a job", "flag": "💼", "color": 0xFF607D8B},
        {"name": "To build projects", "flag": "🛠️", "color": 0xFFFF5722},
        {"name": "Just exploring", "flag": "🔍", "color": 0xFF795548},
        {"name": "Startup dreams", "flag": "🚀", "color": 0xFFE91E63}
      ]
    },
    {
      "key": "studyTarget",
      "question": "What's your daily coding goal?",
      "options": [
        {"name": "5 mins", "flag": "⏰", "color": 0xFF4CAF50},
        {"name": "10 mins", "flag": "⏰", "color": 0xFF2196F3},
        {"name": "15 mins", "flag": "⏰", "color": 0xFFFF9800},
        {"name": "30 mins", "flag": "⏰", "color": 0xFF9C27B0},
        {"name": "60 mins", "flag": "⏰", "color": 0xFFF44336}
      ]
    }
  ];

  @override
  void initState() {
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
    int totalMainQuestions = questions.length;

    if (currentPage < totalMainQuestions) {
      final q = questions[currentPage];
      return _buildQuestionPage(
        context,
        onBoardingController,
        q["question"],
        q["options"],
        q["key"],
      );
    } else if (currentPage == totalMainQuestions) {
      return _buildSuccessPage();
    }
    return _buildSuccessPage();
  }

  Widget _buildQuestionPage(
      BuildContext context,
      OnboardingController controller,
      String title,
      List<Map<String, dynamic>> options,
      String key) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Color(0xFF1E293B), size: 20),
            onPressed: () {
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
          ),
        ),
        title: Container(
          height: 8,
          width: MediaQuery.of(context).size.width * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentPage + 1) / (questions.length + 4),
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
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
                    final isSelected = selectedOption == option["name"];
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
                            selectedOption = option["name"];
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 18),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : const Color(0xFFE2E8F0),
                              width: isSelected ? 3 : 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color:
                                      Color(option["color"]).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    option["flag"],
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option["name"],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color(option["color"]),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 56,
          decoration: BoxDecoration(
            gradient: selectedOption != null
                ? const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selectedOption != null ? null : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(28),
            boxShadow: selectedOption != null
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
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
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              "CONTINUE",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: selectedOption != null
                    ? Colors.white
                    : const Color(0xFF94A3B8),
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
      backgroundColor: const Color(0xFFF8FAFC),
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
                borderRadius: 12,
              ),
              const SizedBox(height: 40),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(75),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🎉',
                      style: TextStyle(fontSize: 60),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SlideTransition(
                position: _slideAnimation,
                child: const Text(
                  "Welcome to DevLingo!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SlideTransition(
                position: _slideAnimation,
                child: const Text(
                  "Your coding journey starts now",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              SlideTransition(
                position: _slideAnimation,
                child: const Text(
                  "Create a profile to keep track of your journey",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
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
                await authController.googleSignIn();

                MyNavigator.pushNamed(GoPaths.dashboardView);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C4AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text("SIGN IN WITH GOOGLE"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

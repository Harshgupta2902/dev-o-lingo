import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/practise_center_controller.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class PremiumScreen extends StatelessWidget {
  final controller = Get.put(PractiseCenterController());

  PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, secondary, kAccent],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => MyNavigator.pop(),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 28),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: successMain,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SUPER',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content (scrollable to avoid overflow)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'Learners with Super',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'are far more likely to finish',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(text: 'their English course — '),
                            TextSpan(
                              text: '4.2× more likely!',
                              style: TextStyle(color: successMain),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Mascot Character
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [successMain, infoMain],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.school,
                                color: Colors.white, size: 40),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Features List (no Expanded inside scroll)
                      _buildFeatureItem(
                        icon: Icons.refresh,
                        text:
                            'Fix mistakes: strengthen weak topics with the Review feature',
                      ),
                      _buildFeatureItem(
                        icon: Icons.headphones,
                        text: 'Practice speaking and listening anytime',
                      ),
                      _buildFeatureItem(
                        icon: Icons.all_inclusive,
                        text: 'Unlimited hearts',
                      ),
                      _buildFeatureItem(
                        icon: Icons.block,
                        text: 'Ad-free experience',
                      ),
                      _buildFeatureItem(
                        icon: Icons.emoji_events,
                        text: 'Free entry to amazing, limited-time challenges',
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Section with Pricing
              Container(
                decoration: const BoxDecoration(
                  color: cardSurface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Annual Plan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: infoBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: infoMain, width: 2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Annual Plan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kOnSurface,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: successMain,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Save 50%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Text(
                                '₹2,999',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: kOnSurface,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '₹5,999',
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                  color: kMuted,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'per year',
                            style: TextStyle(color: kMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Monthly Plan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Plan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kOnSurface,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '₹499',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: kOnSurface,
                            ),
                          ),
                          Text(
                            'per month',
                            style: TextStyle(color: kMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Subscribe Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.togglePremium();
                          MyNavigator.pop();
                          Get.snackbar(
                            'Success!',
                            'Your Super subscription is now active.',
                            backgroundColor: successMain,
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: infoMain,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Start Super',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      '7-day free trial • Cancel anytime',
                      style: TextStyle(color: kMuted, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

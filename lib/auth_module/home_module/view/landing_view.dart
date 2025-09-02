import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/auth_module/home_module/controller/language_controller.dart';
import 'package:lingolearn/auth_module/home_module/view/bottom_navigation.dart';

final languageController = Get.put(LanguageController());

class LandingView extends StatefulWidget {
  const LandingView({super.key, required this.child});
  final Widget child;
  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return languageController.obx(
      (state) {
        final stats = state?.data?.stats;
        return Container(
          padding:
              const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(Icons.local_fire_department,
                  "${stats?.streak ?? 0}", Colors.orange),
              _buildStatItem(Icons.diamond, "${stats?.gems ?? 0}", Colors.blue),
              _buildStatItem(Icons.star, "${stats?.xp ?? 0}", Colors.purple),
              _buildStatItem(
                  Icons.favorite, "${stats?.hearts ?? 0}", Colors.red),
            ],
          ),
        );
      },
      onLoading: Container(
        padding:
            const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem(Icons.local_fire_department, "0", Colors.orange),
            _buildStatItem(Icons.diamond, "0", Colors.blue),
            _buildStatItem(Icons.star, "0", Colors.purple),
            _buildStatItem(Icons.favorite, "0", Colors.red),
          ],
        ),
      ),
      onError: (error) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

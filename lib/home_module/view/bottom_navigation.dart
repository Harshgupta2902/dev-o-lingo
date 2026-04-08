import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lingolearn/main.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  List<_NavTab> _getFilteredTabs() {
    final stats = userStatsController.rxStats.value;
    final allTabs = [
      _NavTab(
        icon: Icons.home_rounded,
        label: "Home",
        route: GoPaths.dashboardView,
        isVisible: stats?.showHome ?? true,
      ),
      _NavTab(
        icon: Icons.auto_awesome_rounded,
        label: "Stories",
        route: GoPaths.dailyPracticesScreen,
        isVisible: stats?.showDailyPractise ?? true,
      ),
      _NavTab(
        icon: Icons.leaderboard_rounded,
        label: "Rank",
        route: GoPaths.leaderBoardView,
        isVisible: stats?.showLeaderboard ?? true,
      ),
      _NavTab(
        icon: Icons.auto_stories_rounded,
        label: "Learn",
        route: GoPaths.practiceCenterScreen,
        isVisible: stats?.showPractiseCenter ?? true,
      ),
      _NavTab(
        icon: Icons.person_rounded,
        label: "Profile",
        route: GoPaths.profileView,
        isVisible: stats?.showProfile ?? true,
      ),
    ];

    return allTabs.where((tab) => tab.isVisible).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tabs = _getFilteredTabs();
      if (tabs.isEmpty) return const SizedBox.shrink();

      final String currentPath = GoRouterState.of(context).uri.path;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: kDarkSlate.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(tabs.length, (index) {
                final tab = tabs[index];
                // Check if this tab is the active one based on the route
                final isSelected = currentPath.startsWith(tab.route);

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!isSelected) {
                        HapticFeedback.lightImpact();
                        MyNavigator.pushNamed(tab.route);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: isSelected ? 1.15 : 1.0,
                          child: Icon(
                            tab.icon,
                            color: isSelected
                                ? kDarkSlate
                                : kDarkSlate.withValues(alpha: 0.35),
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isSelected ? 4 : 0,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: kDarkSlate,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}

class _NavTab {
  final IconData icon;
  final String label;
  final String route;
  final bool isVisible;

  _NavTab({
    required this.icon,
    required this.label,
    required this.route,
    this.isVisible = true,
  });
}

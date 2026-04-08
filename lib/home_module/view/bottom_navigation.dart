import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lingolearn/utilities/common/key_value_pair_model.dart';
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
  int _index = 0;

  final List<KeyValuePairModel> bars = [
    KeyValuePairModel(key: Icons.home_rounded, value: "Home"),
    KeyValuePairModel(key: Icons.auto_awesome_rounded, value: "Stories"),
    KeyValuePairModel(key: Icons.leaderboard_rounded, value: "Rank"),
    KeyValuePairModel(key: Icons.auto_stories_rounded, value: "Learn"),
    KeyValuePairModel(key: Icons.person_rounded, value: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
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
        child: Container(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(bars.length, (index) {
              final isSelected = _index == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _index = index);
                    _onItemTapped(index);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: isSelected ? 1.15 : 1.0,
                        child: Icon(
                          bars[index].key,
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
  }
}

void _onItemTapped(int index) {
  switch (index) {
    case 0:
      MyNavigator.pushNamed(GoPaths.dashboardView);
      break;
    case 1:
      MyNavigator.pushNamed(GoPaths.dailyPracticesScreen);
      break;
    case 2:
      MyNavigator.pushNamed(GoPaths.leaderBoardView);
      break;
    case 3:
      MyNavigator.pushNamed(GoPaths.practiceCenterScreen);
      break;
    case 4:
      MyNavigator.pushNamed(GoPaths.profileView);
      break;
    default:
      MyNavigator.pushNamed(GoPaths.dashboardView);
  }
}

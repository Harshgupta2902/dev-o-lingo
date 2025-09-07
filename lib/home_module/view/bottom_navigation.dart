import 'package:flutter/material.dart';
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

  List<KeyValuePairModel> bars = [
    KeyValuePairModel(key: Icons.home, value: "Home"),
    KeyValuePairModel(key: Icons.book, value: "Stories"),
    KeyValuePairModel(key: Icons.leaderboard, value: "Leaderboard"),
    KeyValuePairModel(key: Icons.person, value: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (value) {
        setState(() {
          _index = value;
        });
        _onItemTapped(value);
      },
      backgroundColor: Colors.white,
      currentIndex: _index,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kPrimary,
      unselectedItemColor: Colors.black,
      selectedFontSize: 14,
      unselectedFontSize: 14,
      items: List.generate(
        bars.length,
        (index) {
          return BottomNavigationBarItem(
            icon: Icon(
              bars[index].key,
              color: index == _index ? const Color(0xFF6C63FF) : Colors.grey,
              size: 28,
            ),
            label: '',
            tooltip: bars[index].value,
          );
        },
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
      MyNavigator.pushNamed(GoPaths.profileView);
      break;
    default:
      MyNavigator.pushNamed(GoPaths.dashboardView);
  }
}

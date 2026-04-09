import 'package:flutter/material.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key, required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kSecondary.withOpacity(0.5), width: 1.5),
            ),
            child: Icon(
              icon,
              color: kOnSurface.withOpacity(0.8),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'serif',
              fontWeight: FontWeight.w700,
              color: kOnSurface,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

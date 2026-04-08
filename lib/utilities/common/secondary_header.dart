import 'package:flutter/material.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class SecondaryHeader extends StatelessWidget {
  final String? title;
  final Widget? customTitle;
  final String? subtitle;
  final Color? subtitleColor;
  final VoidCallback? onBackTap;
  final bool showBackButton;

  const SecondaryHeader({
    super.key,
    this.title,
    this.customTitle,
    this.subtitle,
    this.subtitleColor,
    this.onBackTap,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: kBorder, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.only(top: 45, left: 16, right: 24, bottom: 16),
      child: Row(
        children: [
          if (showBackButton) ...[
            _buildCircleBackButton(),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle!.toUpperCase(),
                    style: TextStyle(
                      color: subtitleColor ?? kMuted,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                if (customTitle != null)
                  customTitle!
                else if (title != null)
                  Text(
                    title!,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: kDarkSlate,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: kBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onBackTap ?? () => MyNavigator.pop(),
          borderRadius: BorderRadius.circular(100),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_rounded,
              color: kDarkSlate,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

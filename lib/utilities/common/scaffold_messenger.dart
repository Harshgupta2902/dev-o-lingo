import 'package:flutter/material.dart';
import 'package:lingolearn/main.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

enum MessageScaffoldType {
  success,
  error,
  warning,
  information,
}

messageScaffold({
  required String content,
  int duration = 3,
  Enum messageScaffoldType = MessageScaffoldType.success,
  bool isTop = false,
}) {
  Color backgroundColor = infoBackground;
  Color mainColor = infoMain;
  IconData stateIcon = Icons.info_outline_rounded;

  switch (messageScaffoldType) {
    case MessageScaffoldType.success:
      backgroundColor = successBackground;
      mainColor = successMain;
      stateIcon = Icons.check_circle_outline_rounded;
      break;

    case MessageScaffoldType.error:
      backgroundColor = errorBackground;
      mainColor = errorMain;
      stateIcon = Icons.error_outline_rounded;
      break;

    case MessageScaffoldType.warning:
      backgroundColor = warningBackground;
      mainColor = warningMain;
      stateIcon = Icons.warning_amber_rounded;
      break;

    case MessageScaffoldType.information:
      backgroundColor = infoBackground;
      mainColor = infoMain;
      stateIcon = Icons.info_outline_rounded;
      break;
  }

  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      elevation: 0,
      closeIconColor: mainColor,
      showCloseIcon: true,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: mainColor.withOpacity(0.2), width: 1),
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                stateIcon,
                color: mainColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                content,
                style: TextStyle(
                  color: mainColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
      duration: Duration(seconds: duration),
    ),
  );
}

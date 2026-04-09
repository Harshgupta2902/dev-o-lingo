import 'package:flutter/material.dart';
import 'package:lingolearn/utilities/constants/assets_path.dart';

// --- Premium Warm Pastel Palette ---
const Color kBeigeBg = Color(0xFFFDFBF4);
const Color kSoftGray = Color(0xFF9CA3AF);
const Color kDarkSlate = Color(0xFF1F2937);
const Color kAmberAccent = Color(0xFFF59E0B);
const Color kSandyBorder = Color(0xFFDAD6B0);

// --- Global Theme Tokens ---
const Color kPrimary = Color(0xFFEFECCF); // Warm Sandy Primary
const Color kSecondary = Color(0xFFC4B889);
const Color kAccent = kAmberAccent;
const Color kSurface = kBeigeBg;
const Color kOnSurface = kDarkSlate;
const Color kMuted = kSoftGray;
const Color kBorder = kSandyBorder;

// --- Unit Card Pastel Palette ---
const Color kCardPurple = Color(0xFFE5DEFF);
const Color kCardOrange = Color(0xFFFFF4E5);
const Color kCardGreen = Color(0xFFD9F2E6);
const Color kCardPink = Color(0xFFFFE5F1);
const Color kCardYellow = Color(0xFFFFF7D6);
const Color kCardBlue = Color(0xFFE5F1FF);

const List<Color> unitCardColors = [
  kCardPurple,
  kCardOrange,
  kCardGreen,
  kCardPink,
  kCardYellow,
  kCardBlue,
];

// --- Legacy / Functional Colors (Harmonized) ---
const Color successBackground = Color(0xFFF0FDF4);
const Color successMain = Color(0xFF10B981);
const Color errorBackground = Color(0xFFFEF2F2);
const Color errorMain = Color(0xFFEF4444);
const Color warningBackground = Color(0xFFFFFBEB);
const Color warningMain = Color(0xFFF59E0B);
const Color infoBackground = Color(0xFFF0F9FF);
const Color infoMain = Color(0xFF3B82F6);
const Color surface = kSurface;
const Color onSurface = kOnSurface;
const Color border = kBorder;
const Color cardSurface = Colors.white;
const Color selectedBackground = Color(0xFFEFECCF);
const Color selectedBorder = Color(0xFFC4B889);
const Color primary = Color(0xFF4B5563);
const Color secondary = Color(0xFF9CA3AF);
const Color muted = kMuted;
const Color success = successMain;
const Color error = errorMain;
const Color warning = warningMain;
const Color successBorder = Color(0xFFBBF7D0);
const Color errorBorder = Color(0xFFFECACA);

const List<Color> unitColors = [
  Color(0xFFA568CC),
  Color(0xFFFF981F),
  Color(0xFF543ACC)
];

final Map<Color, Map<String, String>> unitColorAssetMap = {
  const Color(0xFFA568CC): {
    'normal': AssetPath.purpleSvg,
    'starred': AssetPath.purpleStarredSvg,
    'inactive': AssetPath.inactiveSvg,
    'inactive_starred': AssetPath.inactiveStarredSvg,
  },
  const Color(0xFFFF981F): {
    'normal': AssetPath.yellowSvg,
    'starred': AssetPath.yellowStarredSvg,
    'inactive': AssetPath.inactiveSvg,
    'inactive_starred': AssetPath.inactiveStarredSvg,
  },
  const Color(0xFF543ACC): {
    'normal': AssetPath.blueSvg,
    'starred': AssetPath.blueStarredSvg,
    'inactive': AssetPath.inactiveSvg,
    'inactive_starred': AssetPath.inactiveStarredSvg,
  },
};

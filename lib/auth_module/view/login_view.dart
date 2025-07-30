// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:lingolearn/auth_module/controller/auth_controller.dart';
// import 'package:lingolearn/ipo_module/controller/default_controller.dart';
// import 'package:lingolearn/ipo_module/view/others/policy_view.dart';
// import 'package:lingolearn/utilities/constants/assets_path.dart';
// import 'package:lingolearn/utilities/navigation/go_paths.dart';
// import 'package:lingolearn/utilities/navigation/navigator.dart';
// import 'package:lingolearn/utilities/theme/app_colors.dart';
//
// final _authController = Get.put(AuthController());
// final _defaultController = Get.put(DefaultApiController());
//

//
// class LoginView extends StatefulWidget {
//   const LoginView({super.key});
//   @override
//   State<LoginView> createState() => _LoginViewState();
// }
//
// class _LoginViewState extends State<LoginView> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(
//       const Duration(milliseconds: 400),
//       () => _authController.googleSignIn(
//         isPop: true,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Column(
//           children: [
//             const SizedBox(height: kToolbarHeight - 20),
//             Align(
//               alignment: Alignment.centerRight,
//               child: IconButton(
//                 onPressed: () => MyNavigator.pop(),
//                 icon: const Icon(
//                   Icons.cancel,
//                   color: Colors.black,
//                   size: 30,
//                 ),
//               ),
//             ),
//             Image.asset(
//               AssetPath.loginLogo,
//               height: MediaQuery.of(context).size.height * 0.27,
//             ),
//             const SizedBox(height: 26),
//             Text(
//               "All About Ipo",
//               style: Theme.of(context)
//                   .textTheme
//                   .headlineMedium
//                   ?.copyWith(color: AppColors.oil, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "Information",
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: AppColors.oil, fontWeight: FontWeight.w500),
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 8),
//                   child: Icon(Icons.circle, color: Colors.grey, size: 12),
//                 ),
//                 Text(
//                   "News",
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: AppColors.oil, fontWeight: FontWeight.w500),
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 8),
//                   child: Icon(Icons.circle, color: Colors.grey, size: 12),
//                 ),
//                 Text(
//                   "Alerts",
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: AppColors.oil, fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 40),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 "Sign up or Log In Now to get Realtime Alerts and access additional Information of GMP, Live Subscription.",
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: AppColors.oil, fontWeight: FontWeight.w500),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 foregroundColor: AppColors.oil,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6)),
//                 side: const BorderSide(color: Colors.grey),
//               ),
//               onPressed: () {
//                 if (_authController.isLoggingIn.value == false) {
//                   _authController.googleSignIn(isPop: true);
//                 }
//               },
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SvgPicture.asset(
//                     AssetPath.googleSvg,
//                     height: 22,
//                     width: 22,
//                   ),
//                   const SizedBox(width: 16),
//                   const Text("Continue with Google"),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 10),
//             RichText(
//               text: TextSpan(
//                 text: "I Accept ",
//                 style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                     color: AppColors.oil, fontWeight: FontWeight.w400),
//                 children: [
//                   TextSpan(
//                     text: "Terms & Conditions",
//                     recognizer: TapGestureRecognizer()
//                       ..onTap = () {
//                         MyNavigator.pushNamed(
//                           GoPaths.policyView,
//                           extra: {
//                             'type': PolicyType.terms,
//                             'policy': _defaultController.state?.terms,
//                           },
//                         );
//                       },
//                     style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                         color: AppColors.primaryColor,
//                         fontWeight: FontWeight.w400),
//                   ),
//                   TextSpan(
//                     text: " and ",
//                     style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                         color: AppColors.oil, fontWeight: FontWeight.w400),
//                   ),
//                   TextSpan(
//                     text: "Privacy Policy",
//                     recognizer: TapGestureRecognizer()
//                       ..onTap = () {
//                         MyNavigator.pushNamed(
//                           GoPaths.policyView,
//                           extra: {
//                             'type': PolicyType.privacy,
//                             'policy': _defaultController.state?.privacy,
//                           },
//                         );
//                       },
//                     style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                         color: AppColors.primaryColor,
//                         fontWeight: FontWeight.w400),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class LoginCard extends StatelessWidget {
//   const LoginCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: [
//           const SizedBox(height: kToolbarHeight - 20),
//           Image.asset(
//             AssetPath.loginLogo,
//             height: MediaQuery.of(context).size.height * 0.27,
//           ),
//           const SizedBox(height: 26),
//           Text(
//             "All About Ipo",
//             style: Theme.of(context)
//                 .textTheme
//                 .headlineMedium
//                 ?.copyWith(color: AppColors.oil, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "Information",
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: AppColors.oil, fontWeight: FontWeight.w500),
//               ),
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 8),
//                 child: Icon(Icons.circle, color: Colors.grey, size: 12),
//               ),
//               Text(
//                 "News",
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: AppColors.oil, fontWeight: FontWeight.w500),
//               ),
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 8),
//                 child: Icon(Icons.circle, color: Colors.grey, size: 12),
//               ),
//               Text(
//                 "Alerts",
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: AppColors.oil, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//           const SizedBox(height: 40),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Text(
//               "Sign up or Log In Now to get Realtime Alerts and access additional Information of GMP, Live Subscription.",
//               style: Theme.of(context)
//                   .textTheme
//                   .bodyMedium
//                   ?.copyWith(color: AppColors.oil, fontWeight: FontWeight.w500),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               foregroundColor: AppColors.oil,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(6)),
//               side: const BorderSide(color: Colors.grey),
//             ),
//             onPressed: () {
//               if (_authController.isLoggingIn.value == false) {
//                 _authController.googleSignIn(isPop: true);
//               }
//             },
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SvgPicture.asset(
//                   AssetPath.googleSvg,
//                   height: 22,
//                   width: 22,
//                 ),
//                 const SizedBox(width: 16),
//                 const Text("Continue with Google"),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           RichText(
//             text: TextSpan(
//               text: "I Accept ",
//               style: Theme.of(context)
//                   .textTheme
//                   .labelMedium
//                   ?.copyWith(color: AppColors.oil, fontWeight: FontWeight.w400),
//               children: [
//                 TextSpan(
//                   text: "Terms & Conditions",
//                   recognizer: TapGestureRecognizer()
//                     ..onTap = () {
//                       MyNavigator.pushNamed(
//                         GoPaths.policyView,
//                         extra: {
//                           'type': PolicyType.terms,
//                           'policy': _defaultController.state?.terms,
//                         },
//                       );
//                     },
//                   style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                       color: AppColors.primaryColor,
//                       fontWeight: FontWeight.w400),
//                 ),
//                 TextSpan(
//                   text: " and ",
//                   style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                       color: AppColors.oil, fontWeight: FontWeight.w400),
//                 ),
//                 TextSpan(
//                   text: "Privacy Policy",
//                   recognizer: TapGestureRecognizer()
//                     ..onTap = () {
//                       MyNavigator.pushNamed(
//                         GoPaths.policyView,
//                         extra: {
//                           'type': PolicyType.privacy,
//                           'policy': _defaultController.state?.privacy,
//                         },
//                       );
//                     },
//                   style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                       color: AppColors.primaryColor,
//                       fontWeight: FontWeight.w400),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingolearn/auth_module/components/polygon_text.dart';
import 'package:lingolearn/utilities/constants/assets_path.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';
import 'package:lingolearn/utilities/theme/core_box_shadow.dart';

enum CallApiType {
  gmp,
  mainSubs,
  smeSubs,
  performance,
  smeCalender,
  mainCalender,
  successIpo,
  leaseIpo,
  none
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const PolygonTextBox(
                  title: "Hi there! I’m El!",
                  direction: TriangleDirection.bottom,
                  offset: 70,
                  borderRadius: 14,
                ),
                const SizedBox(height: 20),

                /// 👋 Emoji or SVG
                SvgPicture.asset(
                  AssetPath.hiImg,
                  height: 180,
                ),
                const SizedBox(height: kToolbarHeight),

                /// 📝 App Name & Tagline
                const Text(
                  'Lingo Learn',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Learn coding languages whenever and\nwherever you want. It\'s free and forever.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
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
              onPressed: () {
                MyNavigator.pushNamed(GoPaths.onBoardingView);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C4AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text("GET STARTED"),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6C4AFF),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              "I ALREADY HAVE AN ACCOUNT",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

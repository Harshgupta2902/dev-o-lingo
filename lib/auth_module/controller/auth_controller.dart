import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lingolearn/auth_module/controller/onboarding_controller.dart';
import 'package:lingolearn/auth_module/models/user_model.dart';
import 'package:lingolearn/utilities/common/scaffold_messenger.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';

final onboardingController = Get.put(OnboardingController());

class AuthController extends GetxController
    with StateMixin<SocialLoginResponse> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  RxBool isLoggingIn = RxBool(false);

  signInSilently() async {
    final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
    return account;
  }

  googleSignIn({bool? isRegister = false}) async {
    debugPrint("AuthController => googleSignIn > started");

    try {
      isLoggingIn.value = true;
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint("AuthController => googleSignIn > canceled by user");
        isLoggingIn.value = false;
        return;
      }

      if (isRegister == false) {
        fetchUserData(googleUser);
      } else {
        await saveUser(googleUser);
        fetchUserData(googleUser);
        MyNavigator.pushNamed(GoPaths.onBoardingView);
      }
    } catch (e) {
      debugPrint("AuthController => Error during Google sign-in: $e");
      messageScaffold(
        content: "Something Went Wrong!",
        messageScaffoldType: MessageScaffoldType.error,
      );
    } finally {
      isLoggingIn.value = false;
      debugPrint("AuthController => googleSignIn > process completed");
    }
  }

  saveUser(GoogleSignInAccount googleUser) async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.socialLogin;
    debugPrint("---------- $apiEndPoint socialLogin Start ----------");
    try {
      final response = await postRequest(
        apiEndPoint: apiEndPoint,
        postData: {
          'uid': googleUser.id,
          'name': googleUser.displayName,
          'email': googleUser.email,
          'photoURL': googleUser.photoUrl,
          'fcm_token': getFCMToken(),
          'provider': "GOOGLE"
        },
      );

      debugPrint("AuthController => socialLogin > Success  $response");

      messageScaffold(
        content: "Welcome onboard, ${googleUser.displayName}",
        messageScaffoldType: MessageScaffoldType.success,
      );
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint socialLogin End With Error ----------");
      debugPrint("AuthController => socialLogin > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint socialLogin End ----------");
    }
  }

  Future<int?> fetchUserData(GoogleSignInAccount googleUser) async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.fetchUserData;
    try {
      final response = await postRequest(
        apiEndPoint: apiEndPoint,
        postData: {
          'uid': googleUser.id,
          'email': googleUser.email,
        },
      );

      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      log("response fetchuserdtata $responseData");

      if (responseData["status"] == false &&
          responseData["code"] == "USER_NOT_FOUND") {
        debugPrint("User not found → going to onboarding flow");

        await saveUser(googleUser);
        MyNavigator.pushNamed(GoPaths.onBoardingView);
        return null;
      }

      final modal = SocialLoginResponse.fromJson(responseData);
      change(modal, status: RxStatus.success());

      setLogin(true);
      log("response fetchuserdtata jwtToken ${modal.data.jwtToken}");

      setJwtToken(modal.data.jwtToken);
      setUuid(modal.data.user.uid, modal.data.user.email);

      messageScaffold(
        content: "Login Successful ${modal.data.user.name}",
        messageScaffoldType: MessageScaffoldType.success,
      );

      return modal.data.user.id;
    } catch (error) {
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- fetchUserData End ----------");
    }
    return null;
  }

  Future<dynamic> submitOnboarding(String id) async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.submitOnboarding;
    debugPrint("---------- $apiEndPoint submitOnboarding Start ----------");
    try {
      final data = await onboardingController.getAllOnboardingData();
      final response = await postRequest(
        apiEndPoint: apiEndPoint,
        postData: {
          'userId': id,
          ...data,
        },
      );

      debugPrint("AuthController => submitOnboarding > Success  $response");
      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;
      return responseData;
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint submitOnboarding End With Error ----------");
      debugPrint("AuthController => submitOnboarding > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint submitOnboarding End ----------");
    }
  }

  Future<void> googleSignOut(BuildContext context) async {
    debugPrint("AuthController => googleSignOut > started");

    try {
      await _googleSignIn.signOut();
      setLogin(false);
      clearPrefs();
      debugPrint("AuthController => Signed out from Google");
      messageScaffold(
        content: "User Logged Out",
        messageScaffoldType: MessageScaffoldType.success,
      );
      MyNavigator.popUntilAndPushNamed(GoPaths.login);
    } catch (e) {
      debugPrint("AuthController => Error during Google sign-out: $e");
      messageScaffold(
        content: "Something Went Wrong!",
        messageScaffoldType: MessageScaffoldType.error,
      );
    } finally {
      debugPrint("AuthController => googleSignOut > process completed");
    }
  }

  updateFCMToken(String email, String uid, String fcmToken) async {
    change(null, status: RxStatus.loading());
    const apiEndPoint = APIEndPoints.updateFcmToken;
    debugPrint("---------- $apiEndPoint updateFCMToken Start ----------");
    try {
      final response = await postRequest(
        apiEndPoint: apiEndPoint,
        postData: {
          'uid': uid,
          'email': email,
          'fcm_token': fcmToken,
        },
      );

      debugPrint("AuthController => updateFCMToken > Success  $response");
    } catch (error) {
      debugPrint(
          "---------- $apiEndPoint updateFCMToken End With Error ----------");
      debugPrint("AuthController => updateFCMToken > Error $error ");
      change(null, status: RxStatus.error());
    } finally {
      debugPrint("---------- $apiEndPoint updateFCMToken End ----------");
    }
  }
}

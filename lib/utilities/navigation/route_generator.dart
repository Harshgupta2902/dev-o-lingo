import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lingolearn/home_module/view/daily_practise_view.dart';
import 'package:lingolearn/home_module/view/dashboard_view.dart';
import 'package:lingolearn/home_module/view/follows_screen.dart';
import 'package:lingolearn/home_module/view/landing_view.dart';
import 'package:lingolearn/home_module/view/leaderboard_view.dart';
import 'package:lingolearn/home_module/view/practice_quiz_screen.dart';
import 'package:lingolearn/home_module/view/practise_center.dart';
import 'package:lingolearn/home_module/view/premium_screen.dart';
import 'package:lingolearn/home_module/view/profile_view.dart';
import 'package:lingolearn/auth_module/view/login_view.dart';
import 'package:lingolearn/auth_module/view/onboarding_view.dart';
import 'package:lingolearn/home_module/view/exercises_view.dart';
import 'package:lingolearn/home_module/view/quiz_screen.dart';
import 'package:lingolearn/home_module/view/result_view.dart';
import 'package:lingolearn/home_module/view/shop/shop_view.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');
final GoRouter goRouterConfig = GoRouter(
  initialLocation: isLoggedIn() ? GoPaths.dashboardView : GoPaths.login,
  navigatorKey: rootNavigatorKey,
  observers: [StatsObserver()],
  routes: [
    //
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return LandingView(
          child: child,
        );
      },
      routes: [
        GoRoute(
          parentNavigatorKey: shellNavigatorKey,
          path: GoPaths.dashboardView,
          name: GoPaths.dashboardView,
          builder: (context, state) {
            return const LessonPathScreen();
          },
        ),
        GoRoute(
          parentNavigatorKey: shellNavigatorKey,
          path: GoPaths.dailyPracticesScreen,
          name: GoPaths.dailyPracticesScreen,
          builder: (context, state) {
            return const DailyPracticesScreen();
          },
        ),
        GoRoute(
          parentNavigatorKey: shellNavigatorKey,
          path: GoPaths.profileView,
          name: GoPaths.profileView,
          builder: (context, state) {
            return const AccountScreen();
          },
        ),
        GoRoute(
          parentNavigatorKey: shellNavigatorKey,
          path: GoPaths.leaderBoardView,
          name: GoPaths.leaderBoardView,
          builder: (context, state) {
            return const LeaderboardScreen();
          },
        ),
        GoRoute(
          parentNavigatorKey: shellNavigatorKey,
          path: GoPaths.practiceCenterScreen,
          name: GoPaths.practiceCenterScreen,
          builder: (context, state) {
            return const PracticeCenterScreen();
          },
        ),
      ],
    ),

    // ------------------   Registration Page Routes   ---------------------------

    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: GoPaths.login,
      name: GoPaths.login,
      builder: (context, state) {
        return const LoginView();
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: GoPaths.onBoardingView,
      name: GoPaths.onBoardingView,
      builder: (context, state) {
        return const OnBoardingView();
      },
    ),

    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: GoPaths.exercisesView,
      name: GoPaths.exercisesView,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        final slug = extras['slug'];
        final lessonId = extras['lessonId'];
        return ExerciseView(
          slug: slug,
          lessonId: lessonId,
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: GoPaths.practicesQuestionScreen,
      name: GoPaths.practicesQuestionScreen,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        final practiceId = extras['practiceId'];
        return PracticeQuizScreen(practiceId: practiceId);
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: GoPaths.questionnaireView,
      name: GoPaths.questionnaireView,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        final questions = extras['questions'];
        final lessonId = extras['lessonId'];
        return QuizScreen(
          questions: questions,
          lessonId: lessonId,
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: GoPaths.resultView,
      name: GoPaths.resultView,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        final totalQuestions = extras['totalQuestions'];
        final correctCount = extras['correctCount'];
        final totalDurationMs = extras['totalDurationMs'];
        final logs = extras['logs'];
        final data = extras['data'];
        return ResultScreen(
          totalQuestions: totalQuestions,
          correctCount: correctCount,
          totalDurationMs: totalDurationMs,
          logs: logs,
          data: data,
        );
      },
    ),

    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: GoPaths.followsView,
      name: GoPaths.followsView,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        final type = extras['type'];
        return FollowsScreen(type: type);
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: GoPaths.practisePremiumView,
      name: GoPaths.practisePremiumView,
      builder: (context, state) {
        return const PremiumScreen();
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: GoPaths.shopScreen,
      name: GoPaths.shopScreen,
      builder: (context, state) {
        return const ShopView();
      },
    ),
  ],
);

class StatsObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (isLoggedIn()) {
      userStatsController.getUserStats();
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (isLoggedIn()) {
      userStatsController.getUserStats();
    }
    super.didPop(route, previousRoute);
  }
}

# Dev-O-Lingo — Flutter App

A gamified language learning mobile app built with Flutter. Users learn programming languages through interactive quizzes, daily practice, streaks, leaderboards, and a virtual economy of hearts and gems.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | GetX |
| Navigation | GoRouter |
| Local Storage | GetStorage |
| Networking | Dio |
| Auth | Firebase Auth + Google Sign-In |
| Notifications | Firebase Messaging + flutter_local_notifications |
| Analytics & Crash | Firebase Analytics + Crashlytics |
| Ads | Google Mobile Ads (Interstitial) |
| In-App Purchase | in_app_purchase (Android + iOS) |
| Font | Nunito |

---

## Project Structure

```
lib/
├── main.dart                  # App entry point, Firebase init, global controllers
├── auth_module/
│   ├── view/                  # LoginView, OnboardingView
│   ├── controller/            # AuthController, OnboardingController
│   ├── models/
│   └── components/
├── home_module/
│   ├── view/                  # Dashboard, Quiz, Result, Practice, Shop, Profile, Leaderboard
│   ├── controller/            # LanguageController, ExercisesController, UserStatsController, etc.
│   ├── models/
│   └── widgets/
└── utilities/
    ├── navigation/            # GoRouter config, route paths
    ├── dio/                   # HTTP client, API endpoints
    ├── firebase/              # Analytics, Crashlytics, Notifications
    ├── theme/                 # Colors, SmoothRectangleBorder
    ├── constants/
    ├── common/
    ├── packages/
    └── skeleton/              # Shimmer loading widgets
```

---

## How It Works

### App Startup (`main.dart`)
1. Initializes GetStorage, Firebase, and FCM background handler.
2. Registers global controllers: `LanguageController`, `UserStatsController`, `AppController`, `AchievementController`.
3. If a JWT token exists in storage, pre-fetches language data and user stats before rendering the app.
4. Launches `MaterialApp.router` with GoRouter and a light theme using the Nunito font.

### Authentication Flow
- **LoginView** — Google Sign-In triggers `AuthController` which calls `POST /auth/social-login`. If the user is new, they are redirected to onboarding.
- **OnboardingView** — Fetches dynamic questions from `GET /auth/getOnboardingQuestions` and submits answers to `POST /auth/submitOnboarding`. On completion, navigates to the main dashboard.

### Core Learning Loop
1. **DashboardView** — Displays a "snake path" of Units → Lessons. Calls `POST /getHomeLangauge`. Lessons beyond `lastCompletedLessonId + 1` are locked.
2. **ExerciseView** — Preview/intro for a lesson. Calls `POST /getExercisesbyId`.
3. **QuizScreen** — MCQ engine. Wrong answers decrement hearts locally. On completion, calls `POST /submitLesson` which returns updated XP, gems, and stats.
4. **ResultView** — Shows score and XP earned. An Interstitial Ad is shown before navigating here.

### Heart System
- Users start with 5 hearts. Each wrong answer costs 1 heart.
- Hearts are tracked locally in `UserStatsController` and synced via `getUserStats` / `submitLesson`.
- At 0 hearts, the quiz is blocked and the user is prompted to visit the Shop.

### Daily Practice
- **DailyPractices** — Weekly calendar view. Calls `GET /daily-practice/week`.
- **PracticeQuiz** — Fetches questions via `POST /get-daily-practice` and submits via `POST /daily-practice/submit`.
- **PracticeCenter** — Review of previously wrong questions via `GET /reviewWrongQuestions`.

### Social & Leaderboard
- **Leaderboard** — Weekly XP rankings via `GET /getLeaderboard`.
- **ProfileView** — User stats (XP, streak, gems) via `POST /getUserProfile` + `GET /getUserStats`.
- **FollowsScreen** — Follow/unfollow users via `POST /follow`, `POST /unfollow`, `GET /followers`, `GET /following`.

### Shop & Monetization
- **ShopView** — Lists items via `GET /shop/items`. Purchases go through native IAP (Google Play / App Store), then verified server-side via `POST /shop/create` → `POST /shop/verify`.
- Ad rewards: watching a rewarded ad calls `POST /ads/reward/hearts` or `POST /ads/reward/gems`.

### Notifications
- FCM handles both foreground and background messages.
- Supports a `countdown` type notification that shows a live countdown timer and auto-dismisses when the event starts.
- Normal notifications are routed to the correct screen via a `path` field in the payload.

---

## Screens & API Map

| Screen | API Endpoint(s) |
|---|---|
| LoginView | `POST /auth/social-login`, `POST /auth/fetchUserData` |
| OnboardingView | `GET /auth/getOnboardingQuestions`, `POST /auth/submitOnboarding` |
| DashboardView | `POST /getHomeLangauge` |
| ExerciseView | `POST /getExercisesbyId` |
| QuizScreen | `POST /submitLesson` |
| DailyPractices | `GET /daily-practice/week` |
| PracticeQuiz | `POST /get-daily-practice`, `POST /daily-practice/submit` |
| PracticeCenter | `GET /reviewWrongQuestions` |
| Leaderboard | `GET /getLeaderboard` |
| ProfileView | `POST /getUserProfile`, `GET /getUserStats` |
| FollowsScreen | `GET /followers`, `GET /following`, `POST /follow`, `POST /unfollow` |
| ShopView | `GET /shop/items`, `POST /shop/create`, `POST /shop/verify` |
| Ads Reward | `POST /ads/reward/hearts`, `POST /ads/reward/gems` |
| Achievements | `GET /achievements` |
| Notifications | `GET /notifications`, `POST /notifications/read-all` |

---

## Getting Started

### Prerequisites
- Flutter SDK `>=3.2.0`
- Android Studio / Xcode
- A Firebase project with Android & iOS apps configured
- `google-services.json` placed in `android/app/`

### Run

```bash
flutter pub get
flutter run
```

### Build (Android)
```bash
flutter build apk --release
```

---

## Environment & Config

- Firebase config is hardcoded in `main.dart` for Android and via `GoogleService-Info.plist` for iOS.
- API base URL is defined in `lib/utilities/dio/` (endpoint constants file).
- JWT token is stored locally via `GetStorage` and sent as `Authorization: Bearer <token>` on all protected requests.

---

## Adding New Features

- **New screen**: Add path in `go_paths.dart` → register in `route_generator.dart` → create a controller if data is needed.
- **New API call**: Add the endpoint constant in `api_end_points.dart` → call via `postRequest` / `getRequest` in the controller.
- **UI components**: Use `SmoothRectangleBorder` for cards, `kPrimary` for brand color, and `StateMixin` for loading/error/success states.

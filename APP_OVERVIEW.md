# Dev-O-Lingo (LingoLearn) - Comprehensive Technical Guide

This document provides a detailed breakdown of every screen, the business logic behind it, and the specific API endpoints it consumes.

---

## 🏗 1. Core Architecture

### **State Management: GetX**
- **Dependency Injection**: Controllers are initialized in `main.dart` (globally) or via `Get.put()` in specific views.
- **Reactivity**: Uses `Obx` and `Rx` variables for real-time UI updates (e.g., heart count changing during a quiz).
- **StateMixin**: Standardizes `loading`, `success`, and `error` states across data-driven screens.

### **Navigation: GoRouter**
- **Route Configuration**: Defined in `lib/utilities/navigation/route_generator.dart`.
- **ShellRoute**: Persists the navigation shell (`LandingView`) for core app tabs.

---

## 📱 2. Screen & API Reference

### **A. Authentication & Onboarding**
| Screen | Purpose | Controller | API Endpoint | Description |
| :--- | :--- | :--- | :--- | :--- |
| **LoginView** | Entry point for Google Social Login. | `AuthController` | `auth/social-login`, `auth/fetchUserData` | Authenticates user and checks if they exist in the DB. If NEW, redirects to Onboarding. |
| **OnBoardingView** | Initial setup to choose language path and goals. | `OnboardingController` | `auth/getOnboardingQuestions`, `auth/submitOnboarding` | Fetches dynamic questions for onboarding and submits user's learning choices. |

### **B. Core Learning (Home Dashboard)**
| Screen | Purpose | Controller | API Endpoint | Description |
| :--- | :--- | :--- | :--- | :--- |
| **DashboardView** | The "Snake Path" of units and lessons. | `LanguageController` | `getHomeLangauge` | Fetches the hierarchy of Units -> Lessons. Local logic handles "unlocked" states. |
| **ExerciseView** | Introduction/Preview of a specific lesson. | `ExercisesController` | `getExercisesbyId` | Loads the instruction or teaser for a lesson before the quiz starts. |
| **QuizScreen** | The interactive MCQ / Question engine. | `ExercisesController` | `submitLesson` | Validates answers locally; submits final score, XP, and time taken to the backend. |
| **ResultView** | Displays score and XP earned after a quiz. | N/A | N/A | UI-only result display with ad integration (Interstitial). |

### **C. Practice & Improvement**
| Screen | Purpose | Controller | API Endpoint | Description |
| :--- | :--- | :--- | :--- | :--- |
| **PracticeCenter** | Review center for "Mistakes" or "Weak Words". | `PractiseCenterController` | `reviewWrongQuestions` | Lists questions the user previously got wrong for focused review. |
| **DailyPractices** | A weekly calendar of practice tests. | `DailyPractiseController` | `daily-practice/week` | Shows a 7-day view of available, completed, or locked practice sessions. |
| **PracticeQuiz** | The quiz engine specifically for daily tests. | `PractiseTestController` | `get-daily-practice`, `daily-practice/submit` | Fetches daily specific questions and submits practice-specific results. |

### **D. Social & Engagement**
| Screen | Purpose | Controller | API Endpoint | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Leaderboard** | Global/Regional user rankings. | `LeaderboardController` | `getLeaderboard` | Fetches and displays top users ranked by XP. |
| **ProfileView** | User profile, stats, and settings. | `ProfileController` | `getUserProfile`, `getUserStats` | Displays XP, Streak, Gems, and following/followers count. |
| **FollowsScreen** | Lists of people user follows or is followed by. | `SocialController` | `followers`, `following`, `follow`, `unfollow` | Manages social connections between users. |

### **E. Shop & Monetization**
| Screen | Purpose | Controller | API Endpoint | Description |
| :--- | :--- | :--- | :--- | :--- |
| **ShopView** | Purchase gems, hearts, or items. | `ShopController` | `shop/items`, `shop/create`, `shop/verify` | Handles native Google/Apple IAP and internal currency logic. |
| **PremiumScreen** | Upsell page for the "Super" or "Premium" tier. | N/A | N/A | Marketing page to showcase premium features. |

---

## � 3. Key Business Logic

### **1. The Heart System**
- **Local Logic**: Hearts are tracked in `UserStatsController`. In `QuizScreen`, a wrong answer decrements local hearts.
- **Sync**: Hearts are synced with the server via `getUserStats` and `submitLesson` (which returns updated stats).
- **Out of Hearts**: If hearts hits 0, the `QuizScreen` prohibits further answers and prompts a visit to the Shop.

### **2. Lesson Progression**
- Controlled by `lastCompletedLessonId` returned in `getHomeLangauge`.
- In `DashboardView`, any lesson with an ID higher than `lastCompletedLessonId + 1` is visually locked/greyed out.

### **3. Ad-Gate Integration**
- Most results are gated behind an Interstitial Ad via `AdsHelper`. The flow is: `Finish Quiz` -> `Show Ad` -> `On Ad Dismiss/Fail` -> `Navigate to ResultView`.

---

## 🛠 4. Developer Notes (How to Proceed)

1. **Adding a Screen**: Define path in `go_paths.dart`, register in `route_generator.dart`, and create a controller if data-driven.
2. **Adding an API**: Add endpoint constant in `api_end_points.dart` and implement mapping in a Controller using `postRequest` or `getRequest`.
3. **UI Consistency**: Use `SmoothRectangleBorder` from utilities for all cards. Use `kPrimary` for highlights.
4. **Error Handling**: Use `StateMixin`'s `onError` to provide retry buttons for failed network requests.

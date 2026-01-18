class APIEndPoints {
  static const live = 'https://dev-o-lingo-api-6laf.vercel.app/api/';
  // static const local = 'http://localhost:3000/api/';
  static const local = 'http://192.168.1.2:3000/api/';

  static const base = live;

  static const socialLogin = "auth/social-login";
  static const fetchUserData = "auth/fetchUserData";
  static const updateFcmToken = "auth/updateFcmToken";
  static const getOnboardingQuestions = "auth/getOnboardingQuestions";
  static const submitOnboarding = "auth/submitOnboarding";

  static const getLanguageData = "getHomeLangauge";
  static const getExercisesbyId = "getExercisesbyId";
  static const submitLesson = "submitLesson";

  static const getUserProfile = "getUserProfile";
  static const getUserStats = "getUserStats";

  static const getDailyPractiseTest = "daily-practice/week";
  static const getPractiseTest = "get-daily-practice";
  static const submitDailyPractice = "daily-practice/submit";

  static const getLeaderboard = "getLeaderboard";

  static const reviewWrongQuestions = "reviewWrongQuestions";

  static const follow = "follow";
  static const unfollow = "unfollow";
  static const followers = "followers";
  static const following = "following";

  static const getShopItems = "shop/items";
  static const verifyShopPurchase = "shop/verify";
  static const createShopOrder = "shop/create";
}

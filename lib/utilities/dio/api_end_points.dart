class APIEndPoints {
  static const live = 'https://ipo-tec-app-api.vercel.app/app/';
  static const local = 'http://10.184.79.123:3020/api/';
  // static const local = 'http://192.168.1.52:3020/api/';

  static const base = local;

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
}

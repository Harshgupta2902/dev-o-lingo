class APIEndPoints {
  static const live = 'https://ipo-tec-app-api.vercel.app/app/';
  static const local = 'http://10.184.79.118:3011/api/';
  // static const local = 'http://192.168.1.52:3011/api/';

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
}

import 'package:get_storage/get_storage.dart';

final prefs = GetStorage();

setLogin(bool login) {
  prefs.write("IS_LOGGED_IN", login);
}

setUuid(String uuid, String email) {
  prefs.write("uuid", uuid);
  prefs.write("email", email);
}

getUuid() {
  return prefs.read("uuid");
}

getEmailId() {
  return prefs.read("email");
}

setJwtToken(String token) {
  prefs.write('JWT_TOKEN', token);
}

setFCMToken(String token) {
  prefs.write('FCM_TOKEN', token);
}

String? getFCMToken() {
  return prefs.read("FCM_TOKEN");
}

isLoggedIn() {
  final loggedIn = prefs.read("IS_LOGGED_IN");
  final uuid = prefs.read("uuid");

  if (loggedIn == null || loggedIn == false) {
    return false;
  }
  return loggedIn == true && uuid != null ? true : false;
}

clearPrefs() async {
  await prefs.erase();
}

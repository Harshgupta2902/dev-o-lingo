import 'package:get_storage/get_storage.dart';
import 'package:lingolearn/utilities/constants/storage_keys.dart';

final prefs = GetStorage();

setLogin(bool login) {
  prefs.write(StorageKeys.isLoggedIn, login);
}

setUuid(String uuid, String email) {
  prefs.write(StorageKeys.uuid, uuid);
  prefs.write(StorageKeys.email, email);
}

getUuid() {
  return prefs.read(StorageKeys.uuid);
}

getEmailId() {
  return prefs.read(StorageKeys.email);
}

setJwtToken(String token) {
  prefs.write(StorageKeys.jwtToken, token);
}

getJwtToken() {
  return prefs.read(StorageKeys.jwtToken);
}

setFCMToken(String token) {
  prefs.write(StorageKeys.fcmToken, token);
}

String? getFCMToken() {
  return prefs.read(StorageKeys.fcmToken);
}

isLoggedIn() {
  final loggedIn = prefs.read(StorageKeys.isLoggedIn);
  final uuid = prefs.read(StorageKeys.uuid);

  if (loggedIn == null || loggedIn == false) {
    return false;
  }
  return loggedIn == true && uuid != null ? true : false;
}

clearPrefs() async {
  await prefs.erase();
}

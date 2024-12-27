//import 'package:encrypt/encrypt.dart';
import 'package:cm_2_git/services/singleton_data.dart';
import 'package:universal_html/html.dart';

class LocalStorageHelper {
  static Storage localStorage = window.localStorage;

  static void saveValue(String key, String value) {
    localStorage[key] = value;
  }

  static String? getValue(String key) {
    return localStorage[key];
  }

  static void removeValue(String key) {
    localStorage.remove(key);
  }

  static void clearAll() {
    localStorage.clear();
  }

  /*static String getPassword() {
    removeValue('PassWord');
    removeValue('User');

    if (localStorage['LocalPassword'] != null) {

      return decrypt(localStorage['LocalPassword']);
    } else {
      return '';
    }
  }
  static void savePassword(String value) {
    localStorage['LocalPassword'] = encrypt(value);
  }*/

}

/*
String decrypt(plainText) {

  final key = Key.fromUtf8('4b9bcca1-5540-11eb-ed17-072405c5');
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));

  final decrypted = encrypter.decrypt64(plainText, iv: iv);

  return decrypted.toString();
}

String encrypt(String stringPlain) {
  final key = Key.fromUtf8('4b9bcca1-5540-11eb-ed17-072405c5');
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));
  final encrypted = encrypter.encrypt(stringPlain, iv: iv);

  return encrypted.base64;
}
*/

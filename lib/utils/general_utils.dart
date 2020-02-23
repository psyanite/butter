import 'dart:collection';

class Utils {
  static final shareBaseUrl = 'https://burntoast.page.link/?link=https://burntoast.com';

  static int strToInt(String str) {
    return str != null ? int.parse(str) : null;
  }

  static String buildStoreUrl(int id) {
    return '$shareBaseUrl/stores/?id=$id';
  }

  static String buildProfileUrl(int id) {
    return '$shareBaseUrl/profiles/?id=$id';
  }

  static String buildRewardUrl(String code) {
    return '$shareBaseUrl/rewards/?code=$code';
  }

  static String buildStoreQrCode(int id) {
    return ':stores:$id';
  }

  static String buildProfileQrCode(int id) {
    return ':profiles:$id';
  }

  static String buildRewardQrCode(String code) {
    return ':rewards:$code';
  }

  static List<dynamic> subset(Iterable<int> ids, LinkedHashMap<int, dynamic> map) {
    return ids == null || map == null ? null : ids.map((i) => map[i]).toList();
  }

  static String validateUsername(String name) {
    if (name == null || name.isEmpty) {
      return 'Oops! Usernames can\'t be blank';
    }
    if (name.length > 24) {
      return 'Sorry, usernames have to be shorter than 24 characters';
    }
    var allow = '0123456789abcdefghijklmnopqrstuvwxyz._'.split('');
    if (!name.split('').every((char) => allow.contains(char))) {
      return 'Sorry, usernames can only have lowercase letters, numbers, underscores, and periods';
    }
    return null;
  }

  static String validateEmail(String email) {
    if (email == null || email.isEmpty) {
      return 'Oops! Email can\'t be blank';
    }
    var regex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!regex.hasMatch(email)) {
      return 'Sorry, email address is invalid';
    }
    return null;
  }

  static String buildEmail(String subject, String body) {
    return 'mailto:burntoastfix@gmail.com?subject=$subject&body=Hi there,\n\n\n$body';
  }
}

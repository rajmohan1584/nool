import 'dart:io';

import 'package:nool/utils/log.dart';

class API {
  static Future<bool> hasInternetConnection() async {
    try {
      NLog.log("has Internet Connection - looking up google.com");
      final result = await InternetAddress.lookup('google.com');
      NLog.log("has Internet Connection - result");
      NLog.log(result.toString());

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        NLog.log("has Internet Connection - TRUE");
        return true;
      }
    } on SocketException catch (e) {
      NLog.log("has Internet Connection - SocketException");
      NLog.log(e.toString());
      return false;
    }
    NLog.log("has Internet Connection - WTF?");
    return false;
  }
}

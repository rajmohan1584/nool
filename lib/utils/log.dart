import 'package:flutter/foundation.dart';

class NLog {
  static log(Object s) {
    if (kDebugMode) {
      print(s);
    }
  }
}

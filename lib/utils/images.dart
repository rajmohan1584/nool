import 'package:flutter/material.dart';

const status = ['pending', 'complete', 'partial', 'warning', 'error'];

class IMAGES {
  static Image assetImage(String file,
      {double width = 30, double height = 30, color}) {
    return Image.asset('assets/images/$file',
        width: width, height: height, color: color);
  }

  static Image statusImage(String s) {
    if (!status.contains(s)) {
      s = "error";
    }

    String png = 'assets/images/$s.png';

    return Image.asset(
      png,
      fit: BoxFit.cover,
      width: 20.0,
      height: 20.0,
    );
  }
}

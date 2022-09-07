import 'package:flutter/material.dart';

class IMAGES {
  static Image assetImage(String file,
      {double width = 30, double height = 30, color}) {
    return Image.asset('assets/images/$file',
        width: width, height: height, color: color);
  }
}

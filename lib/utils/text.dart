import 'package:flutter/material.dart';

class TEXT {
  static Widget nameText(String name) {
    return Text(name, style: const TextStyle(fontSize: 12.0));
  }

  static Widget valueText(String value, {bool ellipsis = false}) {
    if (ellipsis) {
      return Flexible(
          child: Text(
        value,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14.0,
        ),
      ));
    }
    return Text(value, style: const TextStyle(fontSize: 14.0));
  }

  static Widget nameValue(String name, String value) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [valueText(value), nameText(name)]);
  }

  static Widget nameValueRow(String name, String value) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          nameText(name),
          const SizedBox(width: 8),
          valueText(value, ellipsis: true)
        ]);
  }

  static Widget bold(String s) {
    return Text(s,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0));
  }
}

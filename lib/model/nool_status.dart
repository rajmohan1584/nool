import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoolStatus {
  const NoolStatus(this.name, this.icon, this.msg);
  final String name;
  final Icon icon;
  final String msg;

  static const List<NoolStatus> all = [
    NoolStatus(
        "delivered",
        Icon(
          CupertinoIcons.checkmark_circle_fill,
          color: Colors.green,
          size: 30,
        ),
        "Books Delivered"),
    NoolStatus(
        "partial",
        Icon(
          CupertinoIcons.circle_lefthalf_fill,
          color: Colors.green,
          size: 30,
        ),
        "Partial Delivery"),
    NoolStatus(
        "pending",
        Icon(
          CupertinoIcons.circle,
          size: 30,
        ),
        "Pending")
  ];

  static Icon statusIcon(String name) {
    for (var s in all) {
      if (s.name == name) return s.icon;
    }

    return const Icon(
      CupertinoIcons.stop_circle_fill,
      size: 30,
      color: Colors.red,
    );
  }
}

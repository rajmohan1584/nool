import 'package:flutter/material.dart';
import 'package:nool/model/nool_status.dart';
import 'package:nool/model/student.dart';
import 'package:nool/utils/text.dart';

class StudentCard extends StatelessWidget {
  const StudentCard({Key? key, required this.student, this.newStatus = ''})
      : super(key: key);
  final Student student;
  final String newStatus;

  @override
  Widget build(BuildContext context) {
    return buildStudentCard();
  }

  Widget buildStudentCard() {
    final s = student;
    final children = <Widget>[];

    bool isTamil = false;
    // ignore: avoid_function_literals_in_foreach_calls
    final runes = s.studentTamilName.runes;
    for (var rune in runes) {
      if (rune > 128) {
        isTamil = true;
      }
      break;
    }

    if (isTamil) {
      Widget tamilName = Text(s.studentTamilName,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: "Catamaran-VariableFont_wght",
          ));
      children.add(tamilName);
    }

    Widget name = Text("${s.studentFirstName} ${s.studentLastName}",
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));
    children.add(name);
    children.add(const Divider());

    Widget row2 = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TEXT.nameValue("age", "${s.age}yrs"),
          TEXT.nameValue("grade", s.gradeName),
          TEXT.nameValue("sec", s.sectionName),
          TEXT.nameValue("room", s.roomNo),
          TEXT.nameValue("ID", s.studentID),
        ]);
    children.add(row2);
    children.add(const SizedBox(height: 5));

    Widget parentRow = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TEXT.nameValueRow("parent-1", s.parent1Name),
          TEXT.nameValueRow("parent-2", s.parent2Name),
          TEXT.nameValueRow(" email id", s.parentEmailId),
        ]);
    children.add(parentRow);

    String status = s.status;
    if (newStatus.isNotEmpty) status = newStatus;

    Widget statusRow = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(status),
          const SizedBox(width: 5),
          NoolStatus.statusIcon(status),
        ]);
    children.add(statusRow);

    final dHt = isTamil ? 30.0 : 0.0;

    return SizedBox(
      height: 190 + dHt,
      child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          elevation: 5.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: children),
          )),
    );
  }
}

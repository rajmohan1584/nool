import 'package:flutter/material.dart';
import 'package:nool/model/nool_status.dart';
import 'package:nool/model/student.dart';
import 'package:nool/utils/text.dart';

class StudentCard extends StatelessWidget {
  const StudentCard({Key? key, required this.student}) : super(key: key);
  final Student student;

  @override
  Widget build(BuildContext context) {
    return buildStudentCard();
  }

  Widget buildStudentCard() {
    final s = student;
    Widget titleRow = Text("${s.studentFirstName} ${s.studentLastName}",
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));

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

    Widget parentRow = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TEXT.nameValueRow("parent-1", s.parent1Name),
          TEXT.nameValueRow("parent-2", s.parent2Name),
          TEXT.nameValueRow(" email id", s.parentEmailId),
        ]);

    Widget statusRow = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(s.status),
          const SizedBox(width: 5),
          NoolStatus.statusIcon(s.status),
        ]);

    return SizedBox(
      height: 200,
      child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          elevation: 5.0,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: titleRow),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: row2),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: parentRow),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: statusRow)
              ])),
    );
  }
}

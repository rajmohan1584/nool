import 'package:flutter/material.dart';
import 'package:nool/model/nool_status.dart';
import 'package:nool/model/student.dart';
import 'package:nool/utils/text.dart';

class StudentCard extends StatelessWidget {
  const StudentCard(
      {Key? key,
      required this.cardCount,
      required this.student,
      this.newStatus = ''})
      : super(key: key);
  final int cardCount;
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
    children.add(const Divider(color: Colors.grey));

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
    children.add(const Divider());

    Widget parentRow = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TEXT.valueText(s.parent1Name),
          TEXT.valueText(s.parent2Name),
          TEXT.valueText(s.parentEmailId),
        ]);
    children.add(parentRow);

    String status = s.status;
    if (newStatus.isNotEmpty) status = newStatus;

    Widget wstatus = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(status),
          const SizedBox(width: 5),
          NoolStatus.statusIcon(status),
        ]);

    if (cardCount < 0) {
      children.add(wstatus);
    } else {
      Widget count = TEXT.nameText("${s.cardIndex + 1} / $cardCount");
      Widget statusRow = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [count, wstatus],
      );
      children.add(statusRow);
    }
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

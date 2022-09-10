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

    final runes = s.studentTamilName.runes;
    for (var rune in runes) {
      if (rune > 128) {
        isTamil = true;
      }
      break;
    }

    String status = s.status;
    if (newStatus.isNotEmpty) status = newStatus;

    Widget statusIcon = NoolStatus.statusIcon(status);

    if (isTamil) {
      Widget tamilName = Text(s.studentTamilName,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: "Catamaran-VariableFont_wght",
          ));

      children.add(Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[statusIcon, const SizedBox(width: 5), tamilName]));
    }

    Widget name = Text("${s.studentFirstName} ${s.studentLastName}",
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));
    if (!isTamil) {
      children.add(Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[statusIcon, const SizedBox(width: 5), name]));
    } else {
      children.add(name);
    }
    children.add(const Divider(color: Colors.grey));

    Widget row2 = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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

    final wemail = TEXT.valueText(s.parentEmailId, fontSize: 11.0);

    final parentItems = <Widget>[
      TEXT.valueText(s.parent1Name, fontSize: 11.0),
      TEXT.valueText(s.parent2Name, fontSize: 11.0)
    ];
    if (cardCount < 0) {
      parentItems.add(wemail);
    } else {
      Widget wcount =
          TEXT.nameText("${s.cardIndex + 1} / $cardCount", fontSize: 9.0);
      parentItems.add(Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [wemail, wcount]));
    }
    Widget parentRow = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: parentItems);
    children.add(parentRow);

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

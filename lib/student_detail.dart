import 'package:flutter/material.dart';
import 'package:nool/model/student.dart';
import 'package:nool/student_card.dart';

class StudentDetail extends StatefulWidget {
  StudentDetail({Key? key, required this.student}) : super(key: key);
  final Student student;

  @override
  State<StudentDetail> createState() => _StudentDetailState();
}

class _StudentDetailState extends State<StudentDetail> {
  @override
  Widget build(BuildContext context) {
    final name =
        "${widget.student.studentFirstName} ${widget.student.studentLastName}";
    return Scaffold(
        appBar: AppBar(title: Text(name)), body: SafeArea(child: buildBody()));
  }

  Widget buildBody() {
    return StudentCard(student: widget.student);
  }
}

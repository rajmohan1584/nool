import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nool/model/nool_status.dart';
import 'package:nool/model/student.dart';
import 'package:nool/student_card.dart';

class StudentDetail extends StatefulWidget {
  const StudentDetail({Key? key, required this.student, required this.callback})
      : super(key: key);
  final Student student;
  final Future<void> Function(String, String) callback;

  @override
  State<StudentDetail> createState() => _StudentDetailState();
}

class _StudentDetailState extends State<StudentDetail> {
  late String status;

  @override
  void initState() {
    status = widget.student.status;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final name =
        "${widget.student.studentFirstName} ${widget.student.studentLastName}";
    return Scaffold(
        appBar: AppBar(title: Text(name)), body: SafeArea(child: buildBody()));
  }

  Widget buildControl() {
    final children = <Widget>[];
    for (var nstat in NoolStatus.all) {
      children.add(nstat.icon);
      children.add(Center(child: Text(nstat.msg)));
      children.add(CupertinoSwitch(
        value: nstat.name == status,
        onChanged: (value) async {
          setState(() {
            status = nstat.name;
          });
          await widget.callback(widget.student.studentID, nstat.name);
        },
      ));
    }

    final grid = SizedBox(
        height: 200,
        child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: (1 / .5),
            padding: const EdgeInsets.all(4.0),
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 4.0,
            children: children));

    const header = Center(
        child: Text("Select Student Status", style: TextStyle(fontSize: 25)));
    return Card(
        margin: const EdgeInsets.all(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [header, const SizedBox(height: 20), grid],
          ),
        ));
  }

  Widget buildBody() {
    return Column(children: [
      StudentCard(cardCount: -1, student: widget.student, newStatus: status),
      Container(
        margin: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(color: Colors.green, spreadRadius: 3),
          ],
        ),
        height: 300,
        child: buildControl(),
      ),
      const SizedBox(
        height: 20,
      ),
      CupertinoButton.filled(
          child: const Text("Done"),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
  }
}

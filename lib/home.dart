import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nool/model/student.dart';
import 'package:nool/student_card.dart';
import 'package:nool/student_detail.dart';
import 'package:nool/utils/log.dart';
import 'package:nool/utils/text.dart';

class NoolHome extends StatefulWidget {
  const NoolHome({Key? key}) : super(key: key);

  @override
  State<NoolHome> createState() => _NoolHomeState();
}

class _NoolHomeState extends State<NoolHome> {
  List<Student> students = [];
  List<Student> filteredStudents = [];
  bool loading = true;
  final searchInputCtlr = TextEditingController();
  Timer? debounce;

  @override
  void initState() {
    //StudentData.load();
    onReloadData();
    super.initState();
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  Future<void> onReloadData({bool silent = false}) async {
    if (!silent) {
      setState(() => loading = true);
      //await Future.delayed(const Duration(milliseconds: 500));
    }

    List<Student> sl = await Student.loadStudents();

    setState(() {
      searchInputCtlr.clear();
      students = sl;
      filteredStudents = sl;
    });

    NLog.log("Loaded ${students.length} students");

    setState(() {
      loading = false;
    });
  }

  onSearchTextChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 250), () {
      query = query.toLowerCase();
      if (query.isEmpty) {
        setState(() {
          filteredStudents = students;
        });
        return;
      }
      NLog.log(query);
      final filtered = students.where((Student s) {
        bool found = false;
        for (var v in s.searchValues) {
          if (v.isNotEmpty && v.startsWith(query)) {
            found = true;
            break;
          }
        }
        return found;
      }).toList();

      setState(() {
        filteredStudents = filtered;
      });
    });
  }

  Widget searchInput() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                  onChanged: onSearchTextChanged,
                  controller: searchInputCtlr,
                  autocorrect: false,
                  obscureText: false,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search',
                      fillColor: Color(0xfff3f3f4),
                      filled: true)),
            ),
            Container(
                height: 50,
                margin: const EdgeInsets.all(0),
                decoration: const BoxDecoration(color: Color(0xfff3f3f4)),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      searchInputCtlr.clear();
                      filteredStudents = students;
                    });
                  },
                  child: const Icon(
                    CupertinoIcons.clear_circled,
                    color: Colors.blue,
                  ),
                ))
          ],
        ));
  }

  Widget buildStudent(Student s) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      StudentDetail(student: s)));
        },
        child: StudentCard(student: s));
  }

  Widget buildList() {
    return ListView.builder(
        itemCount: filteredStudents.length,
        itemBuilder: (ctx, index) {
          Student s = filteredStudents[index];
          return buildStudent(s);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("நூல் விநியோகம்",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Catamaran-VariableFont_wght",
                  color: Colors.white)),
        ),
        body: RefreshIndicator(
            onRefresh: onReloadData,
            child: SafeArea(
                child: Column(children: [
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: searchInput()),
              Expanded(child: buildList())
            ]))));
  }
}

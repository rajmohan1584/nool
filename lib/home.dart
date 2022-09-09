import 'dart:async';

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nool/model/nool_status.dart';
import 'package:nool/model/student.dart';
import 'package:nool/student_card.dart';
import 'package:nool/student_detail.dart';
import 'package:nool/utils/excel.dart';
import 'package:nool/utils/log.dart';
import 'package:collection/collection.dart';
import 'package:nool/utils/pdf.dart';
import 'package:nool/utils/text.dart';

class NoolHome extends StatefulWidget {
  const NoolHome({Key? key}) : super(key: key);

  @override
  State<NoolHome> createState() => _NoolHomeState();
}

class _NoolHomeState extends State<NoolHome> {
  List<Student> students = [];
  List<Student> displayStudents = [];
  bool loading = true;
  final searchInputCtlr = TextEditingController();
  Timer? debounce;
  bool showFilter = true;
  int groupValue = 0;
  List<int> counts = [0, 0, 0, 0];

  @override
  void initState() {
    //StudentData.load();
    _onReloadData();
    listenForChanges();
    super.initState();
  }

  _onReloadData() async {
    await onReloadData();
  }

  /* iOS
  listenForChanges() {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('student_status');
    reference.snapshots().listen((qs) {
      for (var change in qs.docChanges) {
        final doc = change.doc;
        final sid = doc.id;
        final data = doc.data() as Map<String, dynamic>;
        final Student? s = students.firstWhereOrNull(
          (s) => s.studentID == sid,
        );
        if (s != null) {
          setState(() {
            s.status = JSON.parseString(data, "status");
            onFilterData(groupValue, searchInputCtlr.text);
          });
        } else {
          NLog.log("Error");
          NLog.log(data);
        }
        NLog.log(data);
      }
    });
  }
  */

  // Windows
  listenForChanges() {
    final CollectionReference coll =
        Firestore.instance.collection('student_status_w');

    coll.document("*").stream.listen((event) {
      if (event != null) NLog.log(event);
      /*
      for (var change in event) {
        final doc = change.doc;
        final sid = doc.id;
        final data = doc.data() as Map<String, dynamic>;
        final Student? s = students.firstWhereOrNull(
          (s) => s.studentID == sid,
        );
        if (s != null) {
          setState(() {
            s.status = JSON.parseString(data, "status");
            onFilterData(groupValue, searchInputCtlr.text);
          });
        } else {
          NLog.log("Error");
          NLog.log(data);
        }
        NLog.log(data);
      }
    });
    */
    });
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
      displayStudents = sl;
      counts = calcCounts();
    });

    NLog.log("Loaded ${students.length} students");

    setState(() {
      loading = false;
    });
  }

  onFilterData(int g, String query) {
    var filtered = students;

    switch (g) {
      case 1:
        filtered =
            students.where((Student s) => s.status == "delivered").toList();
        break;
      case 2:
        filtered =
            students.where((Student s) => s.status == "partial").toList();
        break;
      case 3:
        filtered =
            students.where((Student s) => s.status == "pending").toList();
        break;
      default:
        break;
    }
    if (groupValue > 0) {}
    query = query.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        displayStudents = filtered;
        counts = calcCounts();
      });
      return;
    }
    NLog.log(query);
    final searchedAndFiltered = filtered.where((Student s) {
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
      displayStudents = searchedAndFiltered;
      counts = calcCounts();
    });
  }

  calcCounts() {
    int c0 = 0, c1 = 0, c2 = 0, c3 = 0;
    c0 = students.length;
    for (var s in students) {
      if (s.status == "delivered") c1++;
      if (s.status == "partial") c2++;
      if (s.status == "pending") c3++;
    }
    return [c0, c1, c2, c3];
  }

  onSearchTextChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 250), () {
      onFilterData(groupValue, query);
    });
  }

  Widget searchInput() {
    final xcolor =
        searchInputCtlr.text.isNotEmpty ? Colors.blue : const Color(0xfff3f3f4);
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 25),
            Flexible(
              child: TextField(
                  onChanged: onSearchTextChanged,
                  controller: searchInputCtlr,
                  autocorrect: false,
                  obscureText: false,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search by Name or ID',
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
                      displayStudents = students;
                    });
                  },
                  child: Icon(
                    CupertinoIcons.clear_circled,
                    color: xcolor,
                  ),
                )),
            const SizedBox(width: 25)
          ],
        ));
  }

  Widget segmentHeader(int g, String status) {
    if (g == 0) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [const Text('All  '), TEXT.bold('${counts[0]}')]));
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NoolStatus.statusIcon(status),
              TEXT.bold('${counts[g]}')
            ]));
  }

  switchSegment(int group) {
    setState(() {
      groupValue = group;
    });
    onFilterData(group, searchInputCtlr.text);
  }

  Widget buildFilter() {
    if (!showFilter) return Container();
    return CupertinoSegmentedControl<int>(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      groupValue: groupValue,
      children: {
        0: segmentHeader(0, ""),
        1: segmentHeader(1, "delivered"),
        2: segmentHeader(2, "partial"),
        3: segmentHeader(3, "pending"),
      },
      onValueChanged: (groupValue) async {
        switchSegment(groupValue);
        NLog.log(groupValue);
      },
    );
  }

  void setStudentStatus(String sid, String status) {
    final Student? s = students.firstWhereOrNull(
      (s) => s.studentID == sid,
    );
    if (s != null) {
      setState(() {
        s.status = status;
        Student.saveStudentStatus(s, status);
      });
      onFilterData(groupValue, searchInputCtlr.text);
    }
  }

  Widget buildStudent(Student s) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => StudentDetail(
                        student: s,
                        callback: setStudentStatus,
                      )));
        },
        child: StudentCard(student: s));
  }

  Widget buildList() {
    return ListView.builder(
        itemCount: displayStudents.length,
        itemBuilder: (ctx, index) {
          Student s = displayStudents[index];
          return buildStudent(s);
        });
  }

  onActionSelected(BuildContext context, int value) {
    switch (value) {
      case 0:
        NExcel.export(displayStudents);
        break;
      case 1:
        NPDF.generate(displayStudents);
        break;

      default:
        break;
    }
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
          actions: [
            PopupMenuButton<int>(
              onSelected: (value) => onActionSelected(context, value),
              itemBuilder: (context) => const [
                PopupMenuItem<int>(value: 0, child: Text("Export to Excel")),
                PopupMenuItem<int>(value: 1, child: Text("Generate PDF")),
                PopupMenuItem<int>(value: 2, child: Text("Print"))
              ],
            )
          ],
        ),
        body: RefreshIndicator(
            onRefresh: onReloadData,
            child: SafeArea(
                child: Column(children: [
              searchInput(),
              buildFilter(),
              Expanded(child: buildList())
            ]))));
  }
}

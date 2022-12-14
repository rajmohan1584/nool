import 'dart:async';

//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firedart/firedart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nool/model/nool_status.dart';
import 'package:nool/model/student.dart';
import 'package:nool/student_card.dart';
import 'package:nool/student_detail.dart';
import 'package:nool/sync_data.dart';
import 'package:nool/utils/alert.dart';
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
    //StudentData.seedDatabase();
    _onReloadData();
    //listenForChanges();
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

  /*
  // Windows
  listenForChanges() {
    final CollectionReference coll =
        Firestore.instance.collection('student_status_w');

    coll.document("*").stream.listen((event) {
      if (event != null) NLog.log(event);
      / *
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
    * /
    });
  }
  */

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

    //List<Student> sl = await Student.loadStudents();
    //List<Student> sl = await Student.loadHardCodedData();
    //List<Student> sl = await Student.getDataFromExcelFile();
    List<Student> sl = await Student.getDataFromCsvFile(context);

    setState(() {
      searchInputCtlr.clear();
      students = sl;
    });
    onFilterData(groupValue, searchInputCtlr.text);

    setState(() {
      loading = false;
      if (!silent) {
        NAlert.alert(context, "Load Complete",
            "Loaded ${students.length} student rows.");
      }
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
        int cardIndex = 0;
        for (var s in displayStudents) {
          s.cardIndex = cardIndex++;
        }
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
      int cardIndex = 0;
      for (var s in displayStudents) {
        s.cardIndex = cardIndex++;
      }
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
                    });
                    onFilterData(groupValue, searchInputCtlr.text);
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
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text('All  ${counts[0]}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue))
          ]));
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          NoolStatus.statusIcon(status),
          Text('${counts[g]}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue))
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
      selectedColor: const Color.fromARGB(255, 196, 221, 245),
      padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
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

  Future<void> setStudentStatus(String sid, String status) async {
    final Student? s = students.firstWhereOrNull(
      (s) => s.studentID == sid,
    );
    if (s != null) {
      setState(() {
        s.status = status;
      });
      await Student.saveStudentStatus(s, status);
      onFilterData(groupValue, searchInputCtlr.text);
    }
  }

  Widget buildStudent(int cardCount, Student s) {
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
        child: StudentCard(cardCount: cardCount, student: s));
  }

  Widget buildList() {
    int cardCount = displayStudents.length;
    return ListView.builder(
        itemCount: cardCount,
        itemBuilder: (ctx, index) {
          Student s = displayStudents[index];
          return buildStudent(cardCount, s);
        });
  }

  onActionSelected(BuildContext context, int value) {
    switch (value) {
      case 0:
        onReloadData();
        break;
      case 1:
        NExcel.export(displayStudents);
        break;
      case 2:
        NPDF.generateFile(context, displayStudents);
        break;
      case 3:
        NPDF.print(displayStudents);
        break;
      case 4:
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const SyncData(
                        uploadCallback: Student.syncStudentStatusDB,
                        downloadCallback: Student.syncStudentStatusMap)))
            .then((value) => onReloadData(silent: true));
        //NAlert.alert(context, "Sync", "TODO");
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const nool = Text("???????????? ???????????????????????????",
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "Catamaran-VariableFont_wght",
            color: Colors.white));
    final ver = TEXT.nameText('2.2', fontSize: 10);

    final title = Row(
      children: [nool, const SizedBox(width: 10), ver],
    );
    return Scaffold(
        appBar: AppBar(
          title: title,
          actions: [
            PopupMenuButton<int>(
              onSelected: (value) => onActionSelected(context, value),
              itemBuilder: (context) => const [
                PopupMenuItem<int>(value: 0, child: Text("Reload CSV")),
                PopupMenuDivider(),
                PopupMenuItem<int>(value: 1, child: Text("Export to Excel")),
                PopupMenuItem<int>(value: 2, child: Text("Generate PDF")),
                PopupMenuItem<int>(value: 3, child: Text("Print")),
                PopupMenuDivider(),
                PopupMenuItem<int>(value: 4, child: Text("Sync to DB")),
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Divider(color: Colors.grey),
              ),
              Expanded(child: buildList())
            ]))));
  }
}

//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firedart/firedart.dart';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:nool/data/student.dart';
import 'package:nool/utils/alert.dart';
import 'package:nool/utils/api.dart';
import 'package:nool/utils/json.dart';
import 'package:nool/utils/log.dart';
import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';

class Student {
  String batch = '';
  String schoolName = '';
  String city = '';
  String gradeName = '';
  String sectionName = '';
  String roomNo = '';
  String studentID = '';
  String studentFirstName = '';
  String studentLastName = '';
  String studentTamilName = '';
  int age = 0;
  String userName = '';
  String parent1Name = '';
  String parent2Name = '';
  String parentEmailId = '';
  String parentAltEmailId = '';

  String status = "pending";
  bool distributed = false;

  List<String> searchValues = [];
  int cardIndex = -1;
/*
      batch = 2022
      schoolName = "NJ Thiruvalluvar Tamil School
      city =  Edison"
      gradeName = EVALUATION
      sectionName = N/A
      roomNo = Cafe
      studentID = 37559
      studentFirstName = Thaarun
      studentLastName = Rajesh
      studentTamilName =
      age = 6
      userName = Psrrajesh81
      parent1Name = Rajesh Ramachandran
      parent2Name = Kanimozhi Paranjothi
      parentEmailId = rajesh.ramachandran81@gmail.com
      parentAltEmailId =
*/

  static Student fromMap(Map<String, dynamic> map) {
    Student s = Student();
    s.batch = JSON.parseString(map, 'batch');
    s.schoolName = JSON.parseString(map, 'schoolName');
    s.city = JSON.parseString(map, 'city');
    s.gradeName = JSON.parseString(map, 'gradeName');
    s.sectionName = JSON.parseString(map, 'sectionName');
    s.roomNo = JSON.parseString(map, 'roomNo');
    s.studentID = JSON.parseString(map, 'studentID');
    s.studentFirstName = JSON.parseString(map, 'studentFirstName');
    s.studentLastName = JSON.parseString(map, 'studentLastName');
    s.studentTamilName = JSON.parseString(map, 'studentTamilName');

    s.age = JSON.parseInt(map, 'age') ?? 0;
    s.userName = JSON.parseString(map, 'userName');
    s.parent1Name = JSON.parseString(map, 'parent1Name');
    s.parent2Name = JSON.parseString(map, 'parent2Name');
    s.parentEmailId = JSON.parseString(map, 'parentEmailId');
    s.parentAltEmailId = JSON.parseString(map, 'parentAltEmailId');

    s.searchValues.add(s.studentID.toLowerCase());
    s.searchValues.add(s.studentFirstName.toLowerCase());
    s.searchValues.add(s.studentLastName.toLowerCase());
    s.searchValues.add(s.parent1Name.toLowerCase());
    s.searchValues.add(s.parent2Name.toLowerCase());
    s.searchValues.add(s.parentEmailId.toLowerCase());

    return s;
  }

  /* iOS
  static Future<List<Student>> loadStudents() async {
    List<Student> students = [];

    await FirebaseFirestore.instance
        .collection('students')
        .get()
        .then((QuerySnapshot qs) {
      for (var doc in qs.docs) {
        final data = doc.data() as Map<String, dynamic>;
        Student s = Student.fromMap(data);
        students.add(s);
        //NLog.log(data);
      }
    });

    await FirebaseFirestore.instance
        .collection('student_status')
        .get()
        .then((QuerySnapshot qs) {
      for (var doc in qs.docs) {
        final sid = doc.id;
        final data = doc.data() as Map<String, dynamic>;
        final Student? s = students.firstWhereOrNull(
          (s) => s.studentID == sid,
        );
        if (s != null) {
          s.status = JSON.parseString(data, "status");
          if (s.status.isEmpty) s.status = "pending";
        } else {
          NLog.log("Error");
          NLog.log(data);
        }
      }
    });
    return students;
  }

  static void saveStudentStatus(Student s, String status) async {
    //status = s;
    if (status.isEmpty) status = "pending";
    final data = {"status": status};
    await FirebaseFirestore.instance
        .collection('student_status')
        .doc(s.studentID)
        .set(data, SetOptions(merge: true));
  }
  */

  /*
  // Windows app
  static Future<List<Student>> loadStudents() async {
    List<Student> students = [];

    //
    // Read students collection
    //
    CollectionReference coll = Firestore.instance.collection('students');
    QueryReference query = coll.orderBy("studentID").limit(100);

    bool done = false;
    while (!done) {
      final List<Document> docs = await query.get();
      NLog.log("Quert returned ${docs.length}");

      for (var doc in docs) {
        Student s = Student.fromMap(doc.map);
        students.add(s);
        //NLog.log(doc);
      }

      if (docs.length < 100) {
        done = true;
      } else {
        final lastStudentID = docs[docs.length - 1]["studentID"];
        query = coll
            .orderBy("studentID")
            .where("studentID", isGreaterThan: lastStudentID)
            .limit(100);
      }
    }

    //
    // Read student_status collection
    //
    coll = Firestore.instance.collection('student_status_w');
    query = coll.orderBy("studentID").limit(100);

    done = false;
    while (!done) {
      final docs = await query.get();
      NLog.log("Query returned ${docs.length}");

      for (var doc in docs) {
        final String studentID = doc["studentID"];
        final Student? s = students.firstWhereOrNull(
          (s) => s.studentID == studentID,
        );
        if (s != null) {
          s.status = JSON.parseString(doc, "status");
          if (s.status.isEmpty) s.status = "pending";
        } else {
          NLog.log("Error");
          NLog.log(doc);
        }
      }

      if (docs.length < 100) {
        done = true;
      } else {
        final String lastStudentID = docs[docs.length - 1]["studentID"];
        query = coll
            .orderBy("studentID")
            .where("studentID", isGreaterThan: lastStudentID)
            .limit(100);
      }
    }

    return students;
  }

  static void saveStudentStatus(Student s, String status) async {
    if (status.isEmpty) status = "pending";

    final String studentID = s.studentID;
    final CollectionReference coll =
        Firestore.instance.collection('student_status_w');
    final QueryReference query = coll.where('studentID', isEqualTo: studentID);
    final List<Document> docs = await query.get();

    var now = DateTime.now();

    if (docs.isEmpty) {
      NLog.log('Adding student_status_w $studentID - $status');
      await coll
          .add({"studentID": studentID, "status": status, "updated": now});
    } else {
      final Document doc = docs[0];
      NLog.log('Adding student_status_w ${doc.id} $studentID - $status');
      await coll.document(doc.id).update({"status": status, "updated": now});
    }

    s.status = status;
  }
  */

  /* Hardcoded */

  static Map<String, dynamic> statusMap = {};

  static Future<List<Student>> loadHardCodedData() async {
    statusMap = await readStudentMap();
    List<Student> sl = StudentData.getHarcodedData();
    statusMap.forEach((sid, status) {
      final Student? s = sl.firstWhereOrNull(
        (s) => s.studentID == sid,
      );
      if (s != null) {
        s.status = status;
      }
    });

    return sl;
  }

  static Future<List<Student>> getDataFromExcelFile() async {
    List<Student> students = [];

    final directory = await getApplicationDocumentsDirectory();
    String filePath = "${directory.path}/Students_Detail_Report_2022.xls";
    File xls = File(filePath);

    var bytes = xls.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      NLog.log(table); //sheet Name
      NLog.log(excel.tables[table]!.maxCols);
      NLog.log(excel.tables[table]!.maxRows);
      for (var row in excel.tables[table]!.rows) {
        NLog.log("$row");
      }
    }

    return students;
  }

  static bool _isTitleLine(List<dynamic> line) {
    if (line.isNotEmpty) {
      if (line[0].startsWith("Students Detail Report")) {
        return true;
      }
    }
    return false;
  }

  static bool _isBlankLine(List<dynamic> line) {
    for (var s in line) {
      if (s.toString().isNotEmpty) return false;
    }
    return true;
  }

  static Future<List<Student>> getDataFromCsvFile(BuildContext context) async {
    List<Student> students = [];
    final List<Map<String, dynamic>> smap = [];

    final directory = await getApplicationDocumentsDirectory();
    String filePath = "${directory.path}/Students_Detail_Report_2022.csv";
    final file = File(filePath);
    if (!file.existsSync()) {
      // ignore: use_build_context_synchronously
      NAlert.alert(context, 'Missing File', filePath);
      return [];
    }
    final csv = File(filePath).openRead();

    final rows = await csv
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();

    final lineCount = rows.length;
    NLog.log("CSV Line Count $lineCount");

    int skippedCount = 0;
    if (lineCount > 0) {
      int iHeader = 0;
      if (_isTitleLine(rows[iHeader])) {
        // This is a title row. Skip it.
        skippedCount++;
        iHeader = 1;
      }
      final List<dynamic> headersRow = rows[iHeader];
      List<String> headers = headersRow.map((e) => e.toString()).toList();
      List<String> fields = [];

      for (var h in headers) {
        h = h.replaceAll(' ', '');
        h = h.replaceAll('.', '');
        h = h.substring(0, 1).toLowerCase() + h.substring(1);
        fields.add(h);
      }
      final fieldCount = fields.length;
      NLog.log(fields);

      for (var i = iHeader + 1; i < lineCount; i++) {
        if (_isBlankLine(rows[i])) {
          // This is a title row. Skip it.
          skippedCount++;
          continue;
        }
        final List<dynamic> values = rows[i];
        final valueCount = values.length;
        if (fieldCount == valueCount) {
          Map<String, dynamic> data = <String, dynamic>{};

          for (var f = 0; f < fieldCount; f++) {
            final String field = fields[f];
            final String rawValue = values[f].toString();
            final String value = rawValue.replaceAll('"', '');
            final bool intField = intFields.contains(field);

            data[fields[f]] = intField ? int.parse(value) : value;
          }
          smap.add(data);
        } else {
          // ignore: use_build_context_synchronously
          NAlert.alert(
              context, "Error Loading CSV", "Error $fieldCount != $valueCount");
          return [];
        }
      }
      for (var m in smap) {
        Student s = Student.fromMap(m);
        students.add(s);
      }
    }

    NLog.log("Loaded ${students.length} rows. Skipped $skippedCount rows.");

    statusMap = await readStudentMap();
    statusMap.forEach((sid, status) {
      final Student? s = students.firstWhereOrNull(
        (s) => s.studentID == sid,
      );
      if (s != null) {
        s.status = status;
      }
    });

    return students;
  }

  static void saveStudentStatus(Student s, String status) async {
    if (status.isEmpty) status = "pending";

    final String studentID = s.studentID;
    statusMap[studentID] = status;

    s.status = status;

    NLog.log(statusMap);

    writeStudentMap();
  }

  static void writeStudentMap() async {
    final directory = await getApplicationDocumentsDirectory();
    String filePath = "${directory.path}/nool_status.map";
    File file = File(filePath);
    String s = '{';
    String delim = '';
    statusMap.forEach((key, value) {
      s += '$delim"$key":"$value"';
      delim = ',';
    });
    s += '}';
    file.writeAsString(s);
  }

  static Future<Map<String, dynamic>> readStudentMap() async {
    final directory = await getApplicationDocumentsDirectory();
    String filePath = "${directory.path}/nool_status.map";

    Map<String, dynamic> m = {};
    File file = File(filePath);
    if (file.existsSync()) {
      try {
        String s = file.readAsStringSync();
        m = jsonDecode(s);
      } catch (e) {
        NLog.log(e.toString());
      }
    }
    return m;
  }

  //
  // Sync Data
  //
  static syncData(BuildContext context) async {
    bool has = await API.hasInternetConnection();
    if (!has) {
      // ignore: use_build_context_synchronously
      NAlert.alert(context, "Sync", "There is no internet connection");
    } else {
      NLog.log("TODO");
    }

    // Read map data
  }
}

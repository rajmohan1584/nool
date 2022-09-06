//import 'package:trueops/model/ratings.dart';
//import 'package:trueops/utils/date_time.dart';
//import 'package:trueops/utils/format.dart';
//import 'package:trueops/utils/json.dart';

//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nool/utils/json.dart';
import 'package:nool/utils/log.dart';

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

  static Future<List<Student>> loadStudents() async {
    /*
    await Firebase.initializeApp(options: DefaultFirebaseOptions.ios)
        .catchError((e) {
      print(" Error : ${e.toString()}");
    });
    */
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

    return students;
  }
}

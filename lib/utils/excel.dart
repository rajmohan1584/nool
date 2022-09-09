import 'dart:io';
import 'dart:core';

import 'package:excel/excel.dart';
import 'package:nool/model/student.dart';
import 'package:nool/utils/log.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class NExcel {
  static export(List<Student> sl) async {
    final st = Stopwatch()..start();

    final excel = Excel.createExcel();
    final String ds = excel.getDefaultSheet()!;
    final sheet = excel[ds];

    int row = 1;
    for (var s in sl) {
      final c1 = CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row++);
      sheet.cell(c1).value = s.studentFirstName;

      final c2 = CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row++);
      sheet.cell(c2).value = s.studentLastName;

      final c3 = CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row++);
      sheet.cell(c3).value = s.studentID;
    }

    // when you are in flutter web then save() downloads the excel file.
    //var fileBytes = excel.save(fileName: "nool.xlsx");

    // Android and iOS
    var fileBytes = excel.save();
    var directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/nool.xlsx";
    NLog.log('Excel Start: $path');
    try {
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);
      OpenFilex.open(path);
    } catch (e) {
      NLog.log(e);
      return;
    }
    NLog.log('Excel Done: ${st.elapsed}');
  }
}

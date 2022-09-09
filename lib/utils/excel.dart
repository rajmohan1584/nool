import 'dart:io';
import 'dart:core';

import 'package:excel/excel.dart';
import 'package:nool/model/student.dart';
import 'package:nool/utils/log.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class NExcel {
  static _addCell(Sheet sheet, int c, int r, dynamic v) {
    final cell = CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r);
    sheet.cell(cell).value = v;
  }

  static export(List<Student> sl) async {
    final st = Stopwatch()..start();

    final Excel excel = Excel.createExcel();
    final String ds = excel.getDefaultSheet()!;
    final Sheet sheet = excel[ds];

    int row = 0;
    for (var s in sl) {
      _addCell(sheet, 0, row, s.batch);
      _addCell(sheet, 1, row, s.schoolName);
      _addCell(sheet, 2, row, s.gradeName);
      _addCell(sheet, 3, row, s.sectionName);
      _addCell(sheet, 4, row, s.roomNo);
      _addCell(sheet, 5, row, s.studentID);
      _addCell(sheet, 6, row, s.studentFirstName);
      _addCell(sheet, 7, row, s.studentLastName);
      _addCell(sheet, 8, row, s.status);

      _addCell(sheet, 9, row, s.age);
      _addCell(sheet, 10, row, s.userName);
      _addCell(sheet, 11, row, s.parent1Name);
      _addCell(sheet, 12, row, s.parent2Name);
      _addCell(sheet, 13, row, s.parentEmailId);
      _addCell(sheet, 14, row, s.parentAltEmailId);

      /*
      final c1 = CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row);
      sheet.cell(c1).value = s.studentFirstName;

      final c2 = CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row);
      sheet.cell(c2).value = s.studentLastName;

      final c3 = CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row);
      sheet.cell(c3).value = s.studentID;
      */

      row++;
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

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:nool/model/student.dart';
import 'package:nool/utils/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class NPDF {
  static pw.Column _buildCol(String v, myStyle) {
    if (v.isEmpty) v = "n/a";
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
//          pw.Text(v, style: const pw.TextStyle(fontSize: 6)),
          pw.Text(v, style: myStyle),
          pw.Divider(thickness: 1)
        ]);
  }

  static pw.TableRow _buildRow(Student s, myStyle) {
    final List<pw.Column> cols = [];
    cols.add(_buildCol(s.studentFirstName, myStyle));
    cols.add(_buildCol(s.studentLastName, myStyle));

    cols.add(_buildCol(s.studentID, myStyle));
    cols.add(_buildCol("  ${s.age}yrs  ", myStyle));
    cols.add(_buildCol(s.status, myStyle));
    cols.add(_buildCol(s.gradeName, myStyle));
    cols.add(_buildCol(s.sectionName, myStyle));
    cols.add(_buildCol(s.roomNo, myStyle));

    cols.add(_buildCol(s.parentEmailId, myStyle));

    return pw.TableRow(children: cols);
  }

  static pw.Document _generatePdf(List<Student> sl, myStyle) {
    final pdf = pw.Document();
    const pageSize = 25;
    for (var i = 0; i < sl.length; i += pageSize) {
      final st = i;
      int ed = i + pageSize;
      if (ed > sl.length) ed = sl.length;

      List<pw.TableRow> rows = [];
      for (var ci = st; ci < ed; ci++) {
        try {
          rows.add(_buildRow(sl[ci], myStyle));
        } catch (e) {
          NLog.log(e.toString());
        }
      }

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.letter,
          orientation: pw.PageOrientation.portrait,
          build: (pw.Context context) {
            return pw.Table(children: rows);
          }));
    }
    /*
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (pw.Context context) {
          return pw.Center(
              child: pw.Table(
                  children: sl.map((s) => _buildRow(s)).toList())); // Center
        }));
    */

    return pdf;
  }

  static generateFile(List<Student> sl) async {
    var data = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    var myFont = pw.Font.ttf(data);
    var myStyle = pw.TextStyle(font: myFont, fontSize: 6);

    final pdf = _generatePdf(sl, myStyle);
    var directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/nool.pdf";
    final file = File(path);

    await file.writeAsBytes(await pdf.save());
  }

  static print(List<Student> sl) async {
    var data = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    var myFont = pw.Font.ttf(data);
    var myStyle = pw.TextStyle(font: myFont, fontSize: 6);

    final pdf = _generatePdf(sl, myStyle);
    /*
    PdfPreview(build: (format) => pdf.save());
    */
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}

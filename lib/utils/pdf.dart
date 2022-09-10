import 'dart:io';

import 'package:nool/model/student.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class NPDF {
  static pw.Column _buildCol(String v) {
    if (v.isEmpty) v = "n/a";
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(v, style: const pw.TextStyle(fontSize: 6)),
          pw.Divider(thickness: 1)
        ]);
  }

  static pw.TableRow _buildRow(Student s) {
    final List<pw.Column> cols = [];
    cols.add(_buildCol(s.studentFirstName));
    cols.add(_buildCol(s.studentLastName));
    cols.add(_buildCol(s.studentTamilName));
    cols.add(_buildCol(s.studentID));
    cols.add(_buildCol("  ${s.age}yrs  "));
    cols.add(_buildCol(s.status));
    cols.add(_buildCol(s.gradeName));
    cols.add(_buildCol(s.sectionName));
    cols.add(_buildCol(s.roomNo));

    cols.add(_buildCol(s.parentEmailId));

    return pw.TableRow(children: cols);
  }

  static pw.Document _generatePdf(List<Student> sl) {
    final pdf = pw.Document();
    const pageSize = 25;
    for (var i = 0; i < sl.length; i += pageSize) {
      final st = i;
      int ed = i + pageSize;
      if (ed > sl.length) ed = sl.length;

      List<pw.TableRow> rows = [];
      for (var ci = st; ci < ed; ci++) {
        rows.add(_buildRow(sl[ci]));
      }

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.letter,
          orientation: pw.PageOrientation.portrait,
          build: (pw.Context context) {
            return pw.Table(children: rows); // Center
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
    final pdf = _generatePdf(sl);
    final file = File("nool.pdf");

    await file.writeAsBytes(await pdf.save());
  }

  static print(List<Student> sl) async {
    final pdf = _generatePdf(sl);
    /*
    PdfPreview(build: (format) => pdf.save());
    */
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}

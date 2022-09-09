import 'dart:io';

import 'package:nool/model/student.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class NPDF {
  static generate(List<Student> sl) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Table(children: [
              for (var i = 0; i < sl.length; i++)
                pw.TableRow(children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(sl[i].studentFirstName,
                            style: pw.TextStyle(fontSize: 6)),
                        pw.Divider(thickness: 1)
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(sl[i].studentLastName,
                            style: pw.TextStyle(fontSize: 6)),
                        pw.Divider(thickness: 1)
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(sl[i].studentID,
                            style: pw.TextStyle(fontSize: 6)),
                        pw.Divider(thickness: 1)
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(sl[i].status, style: pw.TextStyle(fontSize: 6)),
                        pw.Divider(thickness: 1)
                      ])
                ])
            ]),
          ); // Center
        }));

    final file = File("nool.pdf");
    await file.writeAsBytes(await pdf.save());
  }
}

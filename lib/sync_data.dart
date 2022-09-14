import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nool/model/nool_status.dart';
import 'package:nool/model/student.dart';
import 'package:nool/student_card.dart';
import 'package:nool/utils/alert.dart';
import 'package:nool/utils/api.dart';
import 'package:nool/utils/images.dart';
import 'package:nool/utils/log.dart';

class SyncData extends StatefulWidget {
  const SyncData({Key? key}) : super(key: key);

  @override
  State<SyncData> createState() => _SyncDataState();
}

class _SyncDataState extends State<SyncData> {
  bool hasConnection = false;
  Map<String, dynamic> statusMap = {};
  Map<String, dynamic> statusMapDB = {};

  @override
  void initState() {
    onReload();
    super.initState();
  }

  onReload() async {
    bool has = await API.hasInternetConnection();
    setState(() {
      hasConnection = has;
    });

    if (!has) {
      // ignore: use_build_context_synchronously
      NAlert.alert(context, "Sync", "There is no internet connection");
    } else {
      final Map<String, dynamic> m = await Student.readStudentMap();
      final Map<String, dynamic> mDB = await Student.readStudentMapFromDB();
      setState(() {
        statusMap = m;
        statusMapDB = mDB;
      });
      NLog.log("TODO");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Sync to DB')),
        body: SafeArea(child: buildBody()));
  }

  Widget buildBody() {
    String networkMsg;
    String img = "cloud_connected.png";
    if (hasConnection) {
      networkMsg = "Network Connection Exists";
    } else {
      networkMsg = "No Network Connection Found";
      img = "cloud_error.png";
    }

    if (!hasConnection) {
      return Column(children: [
        Container(
            margin: const EdgeInsets.all(30),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IMAGES.assetImage(img),
              const SizedBox(width: 20),
              Text(networkMsg)
            ])),
        const SizedBox(
          height: 20,
        ),
        CupertinoButton.filled(
            child: const Text("Close"),
            onPressed: () {
              Navigator.pop(context);
            })
      ]);
    }

    final count = statusMap.length;
    String statusMsg = "There are $count Status Updates in your local";

    int deliveredCount = 0;
    int partialCount = 0;

    statusMap.forEach((key, value) {
      if (value == "delivered") {
        deliveredCount++;
      } else if (value == "partial") {
        partialCount++;
      }
    });

    return Column(children: [
      Container(
          margin: const EdgeInsets.all(30),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IMAGES.assetImage(img),
            const SizedBox(width: 20),
            Text(networkMsg)
          ])),
      const SizedBox(
        height: 20,
      ),
      const SizedBox(height: 30),
      Text(statusMsg),
      Container(
          margin: const EdgeInsets.all(20),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            NoolStatus.statusIcon("delivered"),
            const SizedBox(width: 20),
            Text("delivered $deliveredCount")
          ])),
      Container(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        NoolStatus.statusIcon("partial"),
        const SizedBox(width: 20),
        Text("partial $partialCount")
      ])),
    ]);
  }
}

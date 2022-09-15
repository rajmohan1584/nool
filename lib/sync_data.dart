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
  const SyncData(
      {Key? key, required this.uploadCallback, required this.downloadCallback})
      : super(key: key);
  final Future<void> Function(String, String) uploadCallback;
  final Future<void> Function(Map<String, dynamic>) downloadCallback;

  @override
  State<SyncData> createState() => _SyncDataState();
}

class _SyncDataState extends State<SyncData> {
  bool hasConnection = false;
  bool uploadNeeded = false;
  bool downloadNeeded = false;
  bool uploading = false;
  bool downloading = false;
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
        uploadNeeded = cloudNeedsUpload(mDB, m);
        downloadNeeded = localNeedsDownload(m, mDB);
        uploading = false;
        downloading = false;
      });
    }
  }

  bool cloudNeedsUpload(Map<String, dynamic> mDB, Map<String, dynamic> m) {
    // Does cloud need updating.
    bool bDirty = false;
    m.forEach((key, value) {
      if (value == "delivered" || value == "partial") {
        final dbValue = mDB[key];
        if (value != dbValue) {
          bDirty = true;
          //NLog.log("Upload Needed $key = $value");
        } else {
          //NLog.log("$key ${mDB[key]} = ${m[key]}");
        }
      } else {
        NLog.log("Warning in local value - $key ${mDB[key]} = ${m[key]}");
      }
    });
    return bDirty;
  }

  bool localNeedsDownload(Map<String, dynamic> m, Map<String, dynamic> mDB) {
    // Does local need updating.
    bool bDirty = false;
    mDB.forEach((key, value) {
      if (value == "delivered" || value == "partial") {
        final dbValue = m[key];
        if (value != dbValue) {
          bDirty = true;
          //NLog.log("Download Needed $key = $value");
        } else {
          //NLog.log("$key ${mDB[key]} = ${m[key]}");
        }
      } else {
        NLog.log("Warning in DB value - $key ${mDB[key]} = ${m[key]}");
      }
    });
    return bDirty;
  }

  Future<void> uploadLocalToCloud() async {
    setState(() => uploading = true);

    for (var key in statusMap.keys) {
      final value = statusMap[key];
      final dbValue = statusMapDB[key];
      if (value == "delivered" || value == "partial") {
        if (value != dbValue) {
          //NLog.log("Calling Upload Callback $key = $value");
          await widget.uploadCallback(key, value);
        } else {
          //NLog.log("$key value = dbValue");
        }
      } else {
        NLog.log("Warning in local value - $key=$value");
      }
    }
    await onReload();
  }

  Future<void> downloadFromCloud() async {
    for (var key in statusMapDB.keys) {
      final dbValue = statusMapDB[key];
      final value = statusMap[key];
      if (dbValue == "delivered" || dbValue == "partial") {
        if (value != dbValue) {
          //NLog.log("Calling Download Callback $key = $value");
          statusMap[key] = dbValue;
        } else {
          //NLog.log("$key value = dbValue");
        }
      } else {
        NLog.log("Warning in local value - $key=$value");
      }
    }
    await widget.downloadCallback(statusMap);
    await onReload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Sync to DB')),
        body: SafeArea(child: buildBody()));
  }

  genStatusInfo(Map<String, dynamic> m, children) {
    int deliveredCount = 0;
    int partialCount = 0;

    m.forEach((key, value) {
      if (value == "delivered") {
        deliveredCount++;
      } else if (value == "partial") {
        partialCount++;
      }
    });

    children.add(const SizedBox(height: 30));
    children.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NoolStatus.statusIcon("delivered"),
          const SizedBox(width: 10),
          Text(" $deliveredCount  delivered")
        ]));
    children.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NoolStatus.statusIcon("partial"),
          const SizedBox(width: 10),
          Text("  $partialCount  partial    ")
        ]));
    children.add(const SizedBox(height: 30));
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

    final count = statusMap.length;
    String statusMsg = "There are $count Status Updates in your local";

    final columnChildren = <Widget>[
      const SizedBox(height: 30),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IMAGES.assetImage(img),
        const SizedBox(width: 20),
        Text(networkMsg)
      ]),
      const SizedBox(height: 20),
      const Divider(color: Colors.blue),
      const SizedBox(height: 20),
      Text(statusMsg),
    ];

    genStatusInfo(statusMap, columnChildren);

    if (!hasConnection) {
      columnChildren.add(const Divider(color: Colors.blue));
      columnChildren.add(CupertinoButton.filled(
          child: const Text("Close"),
          onPressed: () {
            Navigator.pop(context);
          }));
      return Column(children: columnChildren);
    }

    if (uploadNeeded) {
      // Need to upload.
      if (downloading || uploading) {
        columnChildren.add(CupertinoButton.filled(
            onPressed: () {},
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 1.5,
            )));
      } else {
        columnChildren.add(CupertinoButton.filled(
            child: const Text("Upload"),
            onPressed: () async {
              await uploadLocalToCloud();
            }));
      }
    } else {
      columnChildren
          .add(const Text("All local data is available in the Cloud."));
      columnChildren.add(const Text("No Upload required."));
    }

    columnChildren.add(const Divider(color: Colors.blue));

    final countDB = statusMapDB.length;
    String statusMsgDB = "There are $countDB Status Updates the Cloud";

    columnChildren.add(const SizedBox(height: 20));
    columnChildren.add(Text(statusMsgDB));
    genStatusInfo(statusMapDB, columnChildren);

    if (downloadNeeded) {
      // Need to download.
      if (downloading || uploading) {
        columnChildren.add(CupertinoButton.filled(
            onPressed: () {},
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 1.5,
            )));
      } else {
        columnChildren.add(CupertinoButton.filled(
            child: const Text("Download"),
            onPressed: () async {
              await downloadFromCloud();
            }));
      }
      columnChildren.add(const Divider(color: Colors.blue));
    } else {
      columnChildren.add(const Text("All Cloud data is available in Local."));
      columnChildren.add(const Text("No Download required."));
      columnChildren.add(const Divider(color: Colors.blue));
      columnChildren.add(const SizedBox(height: 20));
      columnChildren.add(CupertinoButton.filled(
          child: const Text("Close"),
          onPressed: () {
            Navigator.pop(context);
          }));
    }

    return Column(children: columnChildren);
  }
}

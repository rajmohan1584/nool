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
    String msg;
    String img = "cloud_connected.png";
    if (hasConnection) {
      msg = "Network Connection Exists";
    } else {
      msg = "No Network Connection Found";
      img = "cloud_error.png";
    }
    return Column(children: [
      Container(
          margin: const EdgeInsets.all(30),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IMAGES.assetImage(img),
            const SizedBox(width: 20),
            Text(msg)
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
}

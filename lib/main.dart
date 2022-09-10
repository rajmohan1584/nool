//import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

//import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
//import 'package:nool/firebase_options.dart';
import 'package:nool/home.dart';
import 'package:window_manager/window_manager.dart';

const apiKey = "AIzaSyCbnCd5De6C9Yapr5XccR4tixnzuQ3XZes";
const projectId = "nool-e4a78";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .catchError((e) {
    NLog.log(" Error : ${e.toString()}");
  });
  */
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(400, 1000),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      //titleBarStyle: TitleBarStyle.hidden,
    );

    // Use it only after calling `hiddenWindowAtLaunch`
    windowManager.waitUntilReadyToShow(windowOptions).then((_) async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  //Firestore.initialize(projectId);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOOL',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const NoolHome(),
    );
  }
}

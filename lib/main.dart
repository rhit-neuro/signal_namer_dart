import 'dart:io';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
// import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:signal_namer_dart/pages/fileList.dart';

// import 'firebase_options.dart';
import 'signalNamer.dart';
// import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  const args = String.fromEnvironment("cli");
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // if (!Platform.isLinux) {
  //   await Firebase.initializeApp(
  //       options: DefaultFirebaseOptions.currentPlatform);

  //   FirebaseUIAuth.configureProviders([
  //     GoogleProvider(
  //         clientId:
  //             "14819230507-3hems2rft8sq47r7ueeb338gfrg6fl6a.apps.googleusercontent.com"),
  //   ]);
  // }
  // Must add this line.
  // await windowManager.ensureInitialized();
  print(args);
  if (args == true || args == "true") {
    print("CLI mode");
    // SignalNamer signalNamer = SignalNamer();
    // windowManager.hide();
  } else {
    print("Start GUI");
    runApp(const MyApp());
  }
}

enum PAGES {
  fileList,
  directoryList,
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Signal Namer',
      theme: ThemeData(
        // useMaterial3: true,
        backgroundColor: Color.fromARGB(255, 197, 197, 197),
        canvasColor: Color.fromARGB(255, 197, 197, 197),
        primarySwatch: Colors.blue,
      ),
      home: FileListPage(signalArray: SignalNamer.instance.foundSignals),
    );
  }
}

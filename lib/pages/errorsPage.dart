import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:signal_namer_dart/signalNamer.dart';

import '../models/Error.dart';
import '../models/Signal.dart';

class ErrorsPage extends StatefulWidget {
  String forFile;

  ErrorsPage({super.key, this.forFile = "all"});

  @override
  State<ErrorsPage> createState() => _ErrorsPageState();
}

class _ErrorsPageState extends State<ErrorsPage> {
  int currentLoaded = 0;
  int loadMax = 20;
  List<ListTile> errors = [];
  List<bool> elementsExpanded = [];
  List<ErrorObj> localErrors = [];

  @override
  initState() {
    super.initState();
    currentLoaded = 0;
    errors = [];
    if (this.widget.forFile != "all") {
      localErrors = SignalNamer.instance.errors.where(
        (error) {
          // print(
          // "Checking ${error.fileName} against ${this.widget.forFile.split("/").last}");
          return error.fileName == this.widget.forFile.split("/").last;
        },
      ).toList();
    } else {
      localErrors = SignalNamer.instance.errors;
    }

    _loadMore();
  }

  _loadMore() {
    // print("Loading $loadMax errors currentLoaded: $currentLoaded");
    // print("Errors $errors");
    // int i = 0;
    for (int i = 0; i < loadMax; i++) {
      // while (i < loadMax) {

      int me = i + currentLoaded;
      if (me >= localErrors.length) {
        print("Me was $me");
        break;
      }
      ErrorObj error = SignalNamer.instance.errors[me];
      // bool expanded = SignalNamer.instance.errors[me].expanded;
      // print("Adding ${currentLoaded} + $loadMax");
      print(
          "File: ${this.widget.forFile.split("/").last} and ${error.fileName}");

      errors.add(ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        subtitle: Text(localErrors[me].fullLine),
        title: Row(
          children: [
            Text("[${me}]"),
            Text(localErrors[me].content),
            Text(
              " - ${localErrors[me].fileName} : ",
              textScaleFactor: 0.8,
            ),
            Text(
              "${localErrors[me].line}",
              style: TextStyle(color: Colors.orange),
              textScaleFactor: 0.8,
            ),
          ],
        ),
        trailing: Text("Error Type: ${localErrors[me].type}",
            style: TextStyle(color: Colors.red)),
      ));
      // i++;
    }
    currentLoaded += loadMax;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text("Errors   "),
          Text("(${localErrors.length})",
              textScaleFactor: 0.6, style: TextStyle(color: Colors.orange))
        ]),
      ),
      body: Center(
        child: ListView(
            children: errors,
            padding: EdgeInsets.symmetric(horizontal: 1, vertical: 10)),
      ),
      floatingActionButton: (currentLoaded < localErrors.length)
          ? ElevatedButton(
              child: Text("Load $loadMax more errors"),
              onPressed: () {
                setState(() {
                  _loadMore();
                });
              },
            )
          : null,
    );
  }
}

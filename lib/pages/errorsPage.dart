import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:signal_namer_dart/signalNamer.dart';

import '../models/Error.dart';
import '../models/Signal.dart';

class ErrorsPage extends StatefulWidget {
  const ErrorsPage({super.key});

  @override
  State<ErrorsPage> createState() => _ErrorsPageState();
}

class _ErrorsPageState extends State<ErrorsPage> {
  int currentLoaded = 0;
  int loadMax = 20;
  List<ListTile> errors = [];
  List<bool> elementsExpanded = [];
  @override
  void initState() {
    super.initState();
    currentLoaded = 0;
    errors = [];
    _loadMore();
  }

  _loadMore() {
    // print("Loading $loadMax errors currentLoaded: $currentLoaded");
    // print("Errors $errors");

    for (int i = 0; i < loadMax; i++) {
      if (i >= SignalNamer.instance.errors.length) {
        break;
      }
      int me = i + currentLoaded;
      ErrorObj error = SignalNamer.instance.errors[me];
      // bool expanded = SignalNamer.instance.errors[me].expanded;
      print("Adding ${currentLoaded} + $loadMax");

      errors.add(ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        subtitle: Text(SignalNamer.instance.errors[me].fullLine),
        title: Row(
          children: [
            Text("[${me}]"),
            Text(SignalNamer.instance.errors[me].content),
            Text(
              " - ${SignalNamer.instance.errors[me].fileName} : ",
              textScaleFactor: 0.8,
            ),
            Text(
              "${SignalNamer.instance.errors[me].line}",
              style: TextStyle(color: Colors.orange),
              textScaleFactor: 0.8,
            ),
          ],
        ),
        trailing: Text("Error Type: ${SignalNamer.instance.errors[me].type}",
            style: TextStyle(color: Colors.red)),
      ));
    }

    currentLoaded += loadMax;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text("Errors   "),
          Text("(${SignalNamer.instance.errors.length})",
              textScaleFactor: 0.6, style: TextStyle(color: Colors.orange))
        ]),
      ),
      body: Center(
        child: ListView(
            children: errors,
            padding: EdgeInsets.symmetric(horizontal: 1, vertical: 10)),
      ),
      floatingActionButton: (currentLoaded < SignalNamer.instance.errors.length)
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

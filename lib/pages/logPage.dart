import 'dart:io';

import 'package:event_listener/event_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../components/logManager.dart';
import '../signalNamer.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List<Widget> logs = [];
  bool done = false;
  @override
  initState() {
    super.initState();
    LogManager.instance.logs.forEach((log) {
      logs.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 3),
        child: Text(
          log,
          textScaleFactor: 1.5,
        ),
      ));
    });
  }

  _rebuildLog() {
    setState(() {
      LogManager.instance.logs.forEach((log) {
        logs.add(Text(
          log,
          textScaleFactor: 1.2,
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Logs")),
      body: Center(
        child: ListView(
          children: logs,
          // physics: ScrollPhysics(),
        ),
      ),
      floatingActionButton: (done)
          ? TextButton(
              child: Text("Done"),
              onPressed: () => Navigator.pop(context),
            )
          : null,
    );
  }
}

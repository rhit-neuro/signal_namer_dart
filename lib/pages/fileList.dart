import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:signal_namer_dart/models/SideBar.dart';

import '../alert.dart';
import '../main.dart';
import '../models/Signal.dart';
import '../signalNamer.dart';
import '../utils/fileUtils.dart';

class FileListPage extends StatefulWidget {
  var signalArray;
  bool wasPushed;
  FileListPage({super.key, required this.signalArray, this.wasPushed = false});

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  List<ListTile> signalNames = [];
  @override
  void initState() {
    super.initState();
    _rebuidlList();
  }

  // List<Widget> visualStack = [];
  void removeFromList(Signal currentSignal) {
    // print(signalNames);
    setState(() {
      widget.signalArray.removeWhere(
          (element) => element.signalName == currentSignal.signalName);
      // signalNames.removeWhere((element)=> element.);
      signalNames = [];
      widget.signalArray.forEach((signal) {
        signalNames.add(ListTile(
            title: Text(
              signal.signalName,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
            trailing: IconButton(
              color: Colors.red,
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: (() {
                // print("You pressed a delete button at ${signal.storedAt}");
                removeFromList(signal);
              }),
            )));
      });
    });
  }

  void saveToCSV(BuildContext context) async {
    String? result = await FilePicker.platform.saveFile();
    if (result != null) {
      SignalNamer.instance.exportToCSV(result);
      showAlertDialog(
          context, "Export Successful", "Successfully exported to CSV");
    } else {
      return;
    }
  }

  _rebuidlList() {
    for (Signal signal in widget.signalArray) {
      setState(() {
        signalNames.add(ListTile(
            title: Text(
              signal.signalName,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
            trailing: IconButton(
              color: Colors.red,
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: (() {
                // print("You pressed a delete button at ${signal.storedAt}");
                removeFromList(signal);
              }),
            )));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Signal Namer"),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: ListView(
            children: signalNames,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            signalNames = [];
            getFile(() {
              _rebuidlList();
            });
          },
          child: const Icon(Icons.file_open),
        ),
        drawer: (!widget
                .wasPushed) // only show drawer if we aren't coming from directory
            ? SignalSideBar(currentPage: PAGES.fileList)
            : null);
  }
}

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:signal_namer_dart/components/searchDelegate.dart';
import 'package:signal_namer_dart/models/SideBar.dart';
import 'package:signal_namer_dart/pages/signalPage.dart';

import '../alert.dart';
import '../main.dart';
import '../models/Signal.dart';
import '../signalNamer.dart';
import '../utils/fileUtils.dart';
import 'errorsPage.dart';
import 'logPage.dart';

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
      // widget.signalArray.forEach((signal) {
      //   signalNames.add(ListTile(
      //       title: Text(
      //         signal.signalName,
      //         style: const TextStyle(fontSize: 18, color: Colors.black),
      //       ),
      //       trailing: IconButton(
      //         color: Colors.red,
      //         icon: const Icon(Icons.delete, color: Colors.red),
      //         onPressed: (() {
      //           // print("You pressed a delete button at ${signal.storedAt}");
      //           removeFromList(signal);
      //         }),
      //       )));
      // });
      _rebuidlList();
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
            leading: IconButton(
                // color: Colors.red,
                icon: Icon(
                  Icons.delete,
                ),
                onPressed: (() {
                  // print("You pressed a delete button at ${signal.storedAt}");
                  removeFromList(signal);
                })),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            title: Text(
              signal.signalName,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
            subtitle:
                Text((signal.comment == "") ? "Not Labeled" : signal.comment),
            trailing: IconButton(
              // color: Colors.red,
              icon: Icon(
                Icons.chevron_right,
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return SignalPage(
                        signal: signal,
                      );
                    },
                  ),
                );
                setState(() {});
              },
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
          title: Text("DECA Documenter"),

          actions: [
            IconButton(
              onPressed: () {
                showSearch(context: context, delegate: CustomSearchDelegate());
              },
              icon: Icon(Icons.search),
            ),
            IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return LogPage();
                    },
                  ),
                );
              },
              icon: Icon(Icons.info),
            ),
            IconButton(
              color: Colors.orange[200],
              onPressed: (SignalNamer.instance.errors.isEmpty)
                  ? null
                  : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return ErrorsPage(
                                forFile:
                                    this.widget.signalArray.first.fileName);
                          },
                        ),
                      );
                    },
              icon: Icon(Icons.warning),
            )
          ],
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: ListView(
            children: signalNames,
          ),
        ),
        floatingActionButton: (!widget.wasPushed)
            ? FloatingActionButton(
                onPressed: () {
                  signalNames = [];
                  fromVerilog(() {
                    widget.signalArray = SignalNamer.instance.foundSignals;
                    _rebuidlList();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text((SignalNamer.instance.errors.isEmpty)
                              ? "Found ${SignalNamer.instance.foundSignals.length} signals"
                              : "Found ${SignalNamer.instance.foundSignals.length} signals with ${SignalNamer.instance.errors.length} possible failures"),
                          TextButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return LogPage();
                                    },
                                  ),
                                );
                              },
                              child: Text(
                                "View Log",
                                style: TextStyle(color: Colors.blue),
                              )),
                        ],
                      ),
                      duration: Duration(seconds: 5),
                      action: SnackBarAction(
                          label: "View Errors",
                          onPressed: (() async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return ErrorsPage();
                                },
                              ),
                            );
                          })),
                    ));
                  });
                },
                child: const Icon(Icons.file_open),
              )
            : null,
        drawer: (!widget
                .wasPushed) // only show drawer if we aren't coming from directory
            ? SignalSideBar(currentPage: PAGES.fileList)
            : null);
  }
}

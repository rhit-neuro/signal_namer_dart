import 'package:flutter/material.dart';
import 'package:signal_namer_dart/components/dirSearchDelegate.dart';

import 'package:signal_namer_dart/main.dart';
import 'package:signal_namer_dart/pages/diffPage.dart';
import 'package:signal_namer_dart/pages/errorsPage.dart';
import 'package:signal_namer_dart/pages/fileList.dart';
import 'package:signal_namer_dart/pages/logPage.dart';
import 'package:signal_namer_dart/utils/fileUtils.dart';

import '../components/searchDelegate.dart';
import '../models/SideBar.dart';
import '../models/Signal.dart';
import '../signalNamer.dart';
import 'excludePage.dart';

class DirectoryPage extends StatefulWidget {
  bool fromExcel;
  DirectoryPage({super.key, this.fromExcel = false});

  @override
  State<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  final GlobalKey<TooltipState> dirSearchTooltipkey = GlobalKey<TooltipState>();
  final GlobalKey<TooltipState> projModeTooltipkey = GlobalKey<TooltipState>();

  @override
  initState() {
    super.initState();
    _buildList();
  }

  List<ListTile> directoryList = [];
  bool activelyLoading = false;
  List<Signal> lastDeleted = [];
  String lastDeletedKey = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Directory Import"),
        actions: [
          Tooltip(
            key: dirSearchTooltipkey,
            triggerMode: TooltipTriggerMode.manual,
            message: "Search for a file",
            child: IconButton(
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: DirectorySearchDelegate.fromList(
                        searchTerms:
                            SignalNamer.instance.signalMap.keys.toList()));
              },
              icon: Icon(Icons.search),
            ),
          ),
          (!SignalNamer.instance.projectLoaded)
              ? Tooltip(
                  key: projModeTooltipkey,
                  triggerMode: TooltipTriggerMode.manual,
                  message:
                      "Load current Excel file into project mode and open a new directory",
                  child: IconButton(
                    onPressed: (SignalNamer.instance.excelMode)
                        ? () {
                            setState(() {
                              SignalNamer.instance.swapToProjectMode();
                            });
                          }
                        : null,
                    icon: Icon(Icons.change_circle),
                  ),
                )
              : Tooltip(
                  key: projModeTooltipkey,
                  triggerMode: TooltipTriggerMode.manual,
                  message:
                      "Show changes between loaded project and current directory",
                  child: IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return DiffPage();
                          },
                        ),
                      );
                    },
                    icon: Icon(Icons.difference),
                  ),
                ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return ExcludePage();
                  },
                ),
              );
            },
            icon: Icon(Icons.cancel),
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
                          return ErrorsPage();
                        },
                      ),
                    );
                  },
            icon: Icon(Icons.warning),
          )
        ],
      ),
      body: (SignalNamer.instance.signalMap.length == 0)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "No Files Loaded",
                      style: TextStyle(
                        color: Colors.grey[400],
                      ),
                      textScaleFactor: 3,
                    ),
                  ),
                  (activelyLoading)
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          child: Text("Import a Directory"),
                          onPressed: () => loadDirectories(),
                        ),
                ],
              ),
            )
          : ListView(children: directoryList),
      drawer: SignalSideBar(
        currentPage: PAGES.directoryList,
        dirClearCallback: () {
          _buildList();
          setState(() {});
        },
        loadExcelCallback: () {
          setState(() {
            _buildList();
          });
        },
      ),
    );
  }

  void removeFromList(String currentDir) {
    // print(signalNames);
    setState(() {
      // print("Removing $currentDir");
      // int index = SignalNamer.instance.dirMap.keys.toList().indexOf(currentDir);
      // print("Removing $currentDir at index $index");
      if (!SignalNamer.instance.signalMap.containsKey(currentDir)) {
        return;
      }
      lastDeletedKey = currentDir;
      lastDeleted = SignalNamer.instance.signalMap[currentDir]!;
      SignalNamer.instance.signalMap.remove(currentDir);
      // signalNames.removeWhere((element)=> element.);
      directoryList = [];
      _buildList();
    });
  }

  _buildList() {
    directoryList = [];
    SignalNamer.instance.signalMap.keys.toList().forEach((signalName) {
      directoryList.add(ListTile(
        leading: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            removeFromList(signalName);
            setState(() {});
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //     content: Text("$signalName removed from list!"),
            //     duration: Duration(seconds: 1),
            //     action: SnackBarAction(
            //         label: "Undo",
            //         onPressed: () {
            //           setState(() {
            //             SignalNamer.instance.signalMap[lastDeletedKey] =
            //                 lastDeleted;
            //             directoryList = [];
            //             _buildList();
            //           });
            //         })));
          },
        ),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        style: ListTileStyle.list,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        title: Text(
          signalName.split("/").last,
          textScaleFactor: 2,
        ),
        subtitle: Text(signalName),
        trailing: IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return FileListPage(
                    signalArray: SignalNamer.instance.signalMap[signalName],
                    wasPushed: true,
                  );
                },
              ),
            );
          },
        ),
      ));
    });
  }

  // Future<String?> _spawnAsyncDirFind(String result) async {
  //   return await compute(SignalNamer.instance.directoryFind, result);
  // }

  loadDirectories() async {
    activelyLoading = true;
    setState(() {});

    String? result = await getDir();
    if (result == null) {
      activelyLoading = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No Directory Selected!"),
        duration: Duration(seconds: 5),
      ));
      return;
    }
    // String? error = await _spawnAsyncDirFind(result);
    String? error = SignalNamer.instance.directoryFind(result);
    if (error != null) {
      activelyLoading = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error Loading Directory : $error",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        duration: Duration(seconds: 5),
      ));
      return;
    }
    setState(() {
      activelyLoading = false;
      if (SignalNamer.instance.signalMap.length == 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Verilog files found!"),
          duration: Duration(seconds: 5),
        ));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text((SignalNamer.instance.errors.isEmpty)
                ? "Found ${SignalNamer.instance.signalMap.length} verilog files"
                : "Found ${SignalNamer.instance.signalMap.length} verilog files with ${SignalNamer.instance.errors.length} possible failures"),
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
      _buildList();
    });
  }
}

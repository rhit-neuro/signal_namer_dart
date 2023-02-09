import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:signal_namer_dart/main.dart';
import 'package:signal_namer_dart/pages/errorsPage.dart';
import 'package:signal_namer_dart/pages/fileList.dart';
import 'package:signal_namer_dart/utils/fileUtils.dart';

import '../models/SideBar.dart';
import '../models/Signal.dart';
import '../signalNamer.dart';

class DirectoryPage extends StatefulWidget {
  const DirectoryPage({super.key});

  @override
  State<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  @override
  List<ListTile> directoryList = [];
  bool activelyLoading = false;
  List<Signal> lastDeleted = [];
  String lastDeletedKey = "";
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Signal Namer"),
        actions: [
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
            icon: Icon(Icons.error),
          )
        ],
      ),
      body: (SignalNamer.instance.dirMap.length == 0)
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
          setState(() {});
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
      if (!SignalNamer.instance.dirMap.containsKey(currentDir)) {
        return;
      }
      lastDeletedKey = currentDir;
      lastDeleted = SignalNamer.instance.dirMap[currentDir]!;
      SignalNamer.instance.dirMap.remove(currentDir);
      // signalNames.removeWhere((element)=> element.);
      directoryList = [];
      _buildList();
    });
  }

  _buildList() {
    SignalNamer.instance.dirMap.keys.toList().forEach((signalName) {
      directoryList.add(ListTile(
        leading: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            removeFromList(signalName);
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("$signalName removed from list!"),
                duration: Duration(seconds: 5),
                action: SnackBarAction(
                    label: "Undo",
                    onPressed: () {
                      setState(() {
                        SignalNamer.instance.dirMap[lastDeletedKey] =
                            lastDeleted;
                        directoryList = [];
                        _buildList();
                      });
                    })));
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
                    signalArray: SignalNamer.instance.dirMap[signalName],
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
      if (SignalNamer.instance.dirMap.length == 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Verilog files found!"),
          duration: Duration(seconds: 5),
        ));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text((SignalNamer.instance.errors.isEmpty)
            ? "Found ${SignalNamer.instance.dirMap.length} verilog files"
            : "Found ${SignalNamer.instance.dirMap.length} verilog files with ${SignalNamer.instance.errors.length} possible failures"),
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

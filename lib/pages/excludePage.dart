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

class ExcludePage extends StatefulWidget {
  bool fromExcel;
  ExcludePage({super.key, this.fromExcel = false});

  @override
  State<ExcludePage> createState() => _ExcludePageState();
}

class _ExcludePageState extends State<ExcludePage> {
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
        actions: [],
      ),
      body: ListView(children: directoryList),
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
}

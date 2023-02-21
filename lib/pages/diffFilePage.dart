import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../signalNamer.dart';

class DiffFilePage extends StatefulWidget {
  String toDiff;
  DiffFilePage({super.key, required this.toDiff});

  @override
  State<DiffFilePage> createState() => _DiffFilePageState();
}

class _DiffFilePageState extends State<DiffFilePage> {
  List<DiffObject> diffs = [];
  List<ListTile> tiles = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    diffs = SignalNamer.instance.fileDiff(widget.toDiff);
    tiles = _buildList(diffs);
  }

  _buildList(List<DiffObject> inList) {
    List<ListTile> showing = [];
    setState(() {
      for (DiffObject diffobj in inList) {
        showing.add(
          ListTile(
            title: Text(diffobj.newValue!.signalName),
            subtitle: (diffobj.type == DiffType.CHANGED)
                ? Text("${diffobj.oldValue!.signalName} - Changed")
                : (diffobj.type == DiffType.DELETED)
                    ? Text("Deleted")
                    : Text("New"),
            tileColor: (diffobj.type == DiffType.CHANGED)
                ? Colors.yellow
                : (diffobj.type == DiffType.DELETED)
                    ? Colors.red
                    : (diffobj.type == DiffType.NEW)
                        ? Colors.green
                        : Colors.white,
          ),
        );
      }
    });

    return showing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("File Diff"),
      ),
      body: (tiles.isEmpty)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Text(
                  "No differences found",
                  textScaleFactor: 2,
                  style: TextStyle(color: Colors.grey),
                ))
              ],
            )
          : ListView(
              children: tiles,
            ),
    );
  }
}

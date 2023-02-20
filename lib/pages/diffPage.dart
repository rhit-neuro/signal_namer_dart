import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:signal_namer_dart/pages/diffFilePage.dart';

import '../signalNamer.dart';

class DiffPage extends StatefulWidget {
  const DiffPage({super.key});

  @override
  State<DiffPage> createState() => _DiffPageState();
}

class _DiffPageState extends State<DiffPage> {
  int selectedDir = 0;
  int selectedProj = 0;
  bool _highlightDups = false;
  bool _highlightExisting = false;

  bool _showFullPaths = false;
  bool _showExisting = false;

  _buildList(List<String> objects, selected, tapCallback,
      {bool splitFirst = false, List<String>? checkAgainst = null}) {
    List<ListTile> rtn = [];
    List<String> current = [];

    for (int i = 0; i < objects.length; i++) {
      String toAdd = (splitFirst)
          ? objects[i].split("/").last.split(".").first
          : objects[i];
      if (checkAgainst != null) {
        if (!checkAgainst.contains(toAdd) ||
            _showExisting ||
            _highlightExisting) {
          // Probably should make this into a different function by refactoring or something, but I don't want to
          rtn.add(
            ListTile(
              onTap: () {
                tapCallback(i);
                _buildList(objects, selected, tapCallback,
                    splitFirst: splitFirst);
                setState(() {});
              },
              tileColor: (i == selected)
                  ? Colors.grey
                  : (_highlightExisting && checkAgainst.contains(toAdd))
                      ? Colors.red
                      : (_highlightDups && current.contains(toAdd))
                          ? Colors.blue
                          : Colors.white,
              title: Text((splitFirst)
                  ? objects[i].split("/").last.split(".").first
                  : objects[i]),
              subtitle: (_showFullPaths) ? Text(objects[i]) : null,
            ),
          );
          current.add(toAdd);
          // } else if (_highlightExisting) {
          //   rtn.add(
          //     ListTile(
          //       onTap: null,
          //       tileColor: Colors.red,
          //       title: Text((splitFirst)
          //           ? objects[i].split("/").last.split(".").first
          //           : objects[i]),
          //       subtitle: (_showFullPaths) ? Text(objects[i]) : null,
          //     ),
          //   );
          //   current.add(toAdd);
          // }
        } else {}
      } else {
        rtn.add(
          ListTile(
            onTap: (_highlightExisting)
                ? null
                : () {
                    tapCallback(i);
                    _buildList(objects, selected, tapCallback,
                        splitFirst: splitFirst);
                    setState(() {});
                  },
            tileColor: (i == selected)
                ? Colors.grey
                : (_highlightExisting)
                    ? Colors.red
                    : (_highlightDups && current.contains(toAdd))
                        ? Colors.blue
                        : Colors.white,
            title: Text((splitFirst)
                ? objects[i].split("/").last.split(".").first
                : objects[i]),
          ),
        );
        current.add(toAdd);
      }
    }
    return rtn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Project Diff"),
      ),
      body: Column(
        children: [
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                "Verilog Files Found in Directory",
                textScaleFactor: 2,
              ),
              const Text(
                "Verilog Files in Excel Project",
                textScaleFactor: 2,
              )
            ],
          )),
          Expanded(
            flex: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 4,
                  child: ListView(
                    children: _buildList(
                      SignalNamer.instance.signalMap.keys.toList(),
                      selectedDir,
                      (i) {
                        selectedDir = i;
                      },
                      splitFirst: true,
                      checkAgainst:
                          SignalNamer.instance.loadedProject.keys.toList(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        child: Text("File Diff"),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return DiffFilePage();
                              },
                            ),
                          );
                        },
                      ),
                      CheckboxListTile(
                          title: const Text("Highlight duplicate names"),
                          value: _highlightDups,
                          onChanged: (bool? value) => setState(() {
                                // print("You clicked highlight duplicates");
                                _highlightDups = value!;
                              })),
                      CheckboxListTile(
                          title: const Text("Highlight existing files"),
                          value: _highlightExisting,
                          onChanged: (bool? value) => setState(() {
                                // print("You clicked highlight duplicates");
                                _highlightExisting = value!;
                              })),
                      CheckboxListTile(
                          title: const Text("Show existing files"),
                          value: _showExisting,
                          onChanged: (bool? value) => setState(() {
                                // print("You clicked highlight duplicates");
                                _showExisting = value!;
                              })),
                      CheckboxListTile(
                          title: const Text("Show full file paths"),
                          value: _showFullPaths,
                          onChanged: (bool? value) => setState(() {
                                // print("You clicked highlight duplicates");
                                _showFullPaths = value!;
                              })),
                      IconButton(
                        icon: Icon(Icons.arrow_right),
                        onPressed: () => {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                    flex: 4,
                    child: ListView(
                      children: _buildList(
                        SignalNamer.instance.loadedProject.keys.toList(),
                        selectedProj,
                        (i) {
                          selectedProj = i;
                        },
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

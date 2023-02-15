// import 'dart:ffi';

import 'package:flutter/material.dart';

import '../models/Signal.dart';

class SignalPage extends StatefulWidget {
  Signal signal;
  bool editMode = false;

  SignalPage({super.key, required this.signal});

  @override
  State<SignalPage> createState() => _SignalPageState();
}

class _SignalPageState extends State<SignalPage> {
  final updateTextController = TextEditingController();
  @override
  void dispose() {
    // updateTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DECA Documenter"),
        actions: [
          IconButton(
              color: (widget.editMode) ? Colors.black : Colors.white,
              onPressed: () {
                // print("Edit mode true");
                setState(() {
                  widget.editMode = !widget.editMode;
                });
              },
              icon: const Icon(Icons.edit))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Signal Name: ${widget.signal.signalName}"),
                ElevatedButton(
                    onPressed: (widget.editMode)
                        ? () async {
                            updateTextController.text =
                                widget.signal.signalName;

                            await showEditDiaplog(context, "Signal Name",
                                (result) {
                              setState(() {
                                widget.signal.signalName = result;
                                updateTextController.text = "";
                              });
                            });
                            print("You clicked edit signal name");
                          }
                        : null,
                    child: Text("Edit")),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Comment: ${widget.signal.comment}"),
                ElevatedButton(
                    onPressed: (widget.editMode)
                        ? () async {
                            updateTextController.text = widget.signal.comment;

                            await showEditDiaplog(context, "Comment", (result) {
                              setState(() {
                                widget.signal.comment = result;
                                updateTextController.text = "";
                              });
                            });
                            // print("You clicked edit signal name");
                          }
                        : null,
                    child: Text("Edit")),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Type: ${widget.signal.signalType.name}"),
                ElevatedButton(
                    onPressed: (widget.editMode)
                        ? () async {
                            updateTextController.text =
                                widget.signal.signalType.name;

                            await showSelectType(context, "Signal Type",
                                (result) {
                              // print(result);
                              setState(() {
                                for (SignalType type in SignalType.values) {
                                  print(
                                      "type: ${type.name} and result: $result");
                                  if (type.name == result.toString()) {
                                    widget.signal.signalType = type;
                                    print("Found matching signal");
                                    break;
                                  }
                                }

                                updateTextController.text = "";
                              });
                            });
                            // print("You clicked edit signal name");
                          }
                        : null,
                    child: Text("Edit")),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Is a bus?: ${widget.signal.isBus}"),
                ElevatedButton(
                    onPressed: (widget.editMode)
                        ? () {
                            updateTextController.text =
                                widget.signal.isBus.toString();
                            showYesNoDialog(context, "Is this signal a bus",
                                (result) {
                              setState(() {
                                widget.signal.isBus = result;
                              });
                            });
                          }
                        : null,
                    child: Text("Edit")),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Bus width: ${widget.signal.bitLength}"),
                ElevatedButton(
                    onPressed: (widget.editMode)
                        ? () async {
                            updateTextController.text =
                                widget.signal.bitLength.toString();

                            await showEditDiaplog(context, "Bus width",
                                (result) {
                              setState(() {
                                widget.signal.bitLength = int.parse(result);
                                updateTextController.text = "";
                              });
                            });
                            // print("You clicked edit signal name");
                          }
                        : null,
                    child: Text("Edit")),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("From File: ${widget.signal.fileName}"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Full line: ${widget.signal.rawLine}"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> showEditDiaplog(BuildContext context, String editing, callback) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $editing'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
                child: TextFormField(
                  controller: updateTextController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: editing,
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Update'),
              onPressed: () {
                callback(updateTextController.text);
                Navigator.of(context).pop();
                // return;
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showSelectType(BuildContext context, String editing, callback) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $editing'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
                  child: DropdownMenu(
                    controller: updateTextController,
                    dropdownMenuEntries: SignalType.values
                        .toList()
                        .map((e) => DropdownMenuEntry(label: e.name, value: e))
                        .toList(),
                  )),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Update'),
              onPressed: () {
                callback(updateTextController.text);
                Navigator.of(context).pop();
                // return;
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showYesNoDialog(
      BuildContext context, String question, callback) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$question? '),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
                child: TextFormField(
                  enabled: false,
                  controller: updateTextController,
                  decoration: InputDecoration(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Yes'),
              onPressed: () {
                callback(true);
                Navigator.of(context).pop();
                // return;
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('No'),
              onPressed: () {
                callback(false);
                Navigator.of(context).pop();
                // return;
              },
            ),
          ],
        );
      },
    );
  }
}

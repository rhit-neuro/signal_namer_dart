import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class DiffFilePage extends StatefulWidget {
  const DiffFilePage({super.key});

  @override
  State<DiffFilePage> createState() => _DiffFilePageState();
}

class _DiffFilePageState extends State<DiffFilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("File Diff"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 4,
                  child: ListView(children: []),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [],
                  ),
                ),
                Expanded(flex: 4, child: ListView(children: [])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

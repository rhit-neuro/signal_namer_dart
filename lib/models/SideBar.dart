import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:signal_namer_dart/pages/directoryPage.dart';
import 'package:signal_namer_dart/signalNamer.dart';

import '../main.dart';
import '../utils/fileUtils.dart';

class SignalSideBar extends StatelessWidget {
  final currentPage;
  final Function? dirClearCallback;

  SignalSideBar({required this.currentPage, super.key, this.dirClearCallback});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<TooltipState> dirButtonTooltipkey =
        GlobalKey<TooltipState>();

    return Drawer(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            title: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  );
                },
                child: const Text("Import from Verilog file")),
          ),
          ListTile(
            title: ElevatedButton(
              onHover: (value) {
                dirButtonTooltipkey.currentState?.ensureTooltipVisible();
              },
              onPressed: (kIsWeb)
                  ? null
                  : () async {
                      // getDir();
                      // showAlertDialog(
                      //     context, "Done!", "Finished extracting signals");
                      if (currentPage != PAGES.directoryList) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return DirectoryPage();
                            },
                          ),
                        );
                      }
                    },
              child: Tooltip(
                key: dirButtonTooltipkey,
                triggerMode: TooltipTriggerMode.manual,
                message: (kIsWeb)
                    ? "Directory import is not available on web"
                    : "Load signals from all verilog files in a directory",
                child: Text("Import from Directory"),
              ),
            ),
          ),
          ListTile(
            title: ElevatedButton(
                onPressed: () {
                  saveToExcel(context);
                },
                child: const Text("Export to Excel")),
          ),
          ListTile(
            title: ElevatedButton(
                onPressed: () {
                  SignalNamer.instance.dirMap = Map();
                  if (dirClearCallback != null) {
                    dirClearCallback!();
                  }
                },
                child: const Text("Clear DirMap")),
          )
        ],
      ),
    );
  }
}

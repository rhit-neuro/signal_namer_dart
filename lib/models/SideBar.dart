import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:signal_namer_dart/components/logManager.dart';
import 'package:signal_namer_dart/pages/directoryPage.dart';
import 'package:signal_namer_dart/signalNamer.dart';

import '../main.dart';
import '../utils/fileUtils.dart';

class SignalSideBar extends StatelessWidget {
  final currentPage;
  final Function? dirClearCallback;
  final Function? loadExcelCallback;

  SignalSideBar(
      {required this.currentPage,
      super.key,
      this.dirClearCallback,
      this.loadExcelCallback});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<TooltipState> dirButtonTooltipkey =
        GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> loadFileTooltipkey =
        GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> loadExcelFileTooltipkey =
        GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> clearDirectoryKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> exportTooltipKey = GlobalKey<TooltipState>();
    return Drawer(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            title: ElevatedButton(
              onPressed: (!kIsWeb)
                  ? () {
                      Navigator.popUntil(
                        context,
                        (route) => route.isFirst,
                      );
                    }
                  : null,
              child: Tooltip(
                key: loadFileTooltipkey,
                triggerMode: TooltipTriggerMode.manual,
                message: (kIsWeb)
                    ? "Signal import is not available on web"
                    : "Load signals from a single verilog file",
                child: Text("Import from Verilog file"),
              ),
            ),
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
                SignalNamer.instance.signalMap = Map();
                SignalNamer.instance.errors = [];
                LogManager.instance.logs = [];
                fromExcel(() async {
                  if (currentPage != PAGES.directoryList) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return DirectoryPage(
                            fromExcel: true,
                          );
                        },
                      ),
                    );
                  } else if (loadExcelCallback != null) {
                    loadExcelCallback!();
                  } else {
                    print(
                        "On directory page, but no callback given You shouldn't ever see this!");
                  }
                });
              },
              child: Tooltip(
                child: Text("Import from Excel File"),
                key: loadExcelFileTooltipkey,
                triggerMode: TooltipTriggerMode.manual,
                message: (kIsWeb)
                    ? "Importing from and Excel file is not available on web"
                    : "Import from an Excel file created by this application",
              ),
            ),
          ),
          ListTile(
            title: ElevatedButton(
                onPressed: (!kIsWeb)
                    ? () {
                        saveToExcel(context);
                      }
                    : null,
                child: Tooltip(
                  child: Text("Export to Excel"),
                  key: exportTooltipKey,
                  triggerMode: TooltipTriggerMode.manual,
                  message: (kIsWeb)
                      ? "Can't export to Excel from web"
                      : "Export the signals to an Excel `file",
                )),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: () {
                SignalNamer.instance.signalMap = Map();
                SignalNamer.instance.errors = [];
                LogManager.instance.logs = [];
                if (dirClearCallback != null) {
                  dirClearCallback!();
                }
              },
              child: Tooltip(
                  child: Text("Clear Directory Loads"),
                  key: clearDirectoryKey,
                  triggerMode: TooltipTriggerMode.manual,
                  message: "Clear all loaded files"),
            ),
          ),
        ],
      ),
    );
  }
}

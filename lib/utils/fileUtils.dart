import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../alert.dart';
import '../models/Signal.dart';
import '../signalNamer.dart';

getDir() async {
  String? result = await FilePicker.platform
      .getDirectoryPath(dialogTitle: "Pick a directory");
  if (result == null) {
    return;
  }
  return result;
}

void getFile(callbackFunc) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: "Pick a Verilog file",
    allowMultiple: false,
  );
  dynamic? filename = "";
  if (kIsWeb) {
    print("Web detected, trying to get path from bytes.");
    print(result);
    filename = result?.files.first.bytes;
  } else {
    filename = result?.paths.first!;
  }

  print("Filepath: $filename");
  if (filename != null) {
    SignalNamer.instance.findFromFile(filename, fromWeb: kIsWeb);
    int i = 0;
    callbackFunc();
  }
}

void saveToExcel(BuildContext context) async {
  String? result = await FilePicker.platform.saveFile();
  if (result != null) {
    if (SignalNamer.instance.dirMode) {
      Excel? currentExcel = null;
      int i = 0;
      for (String file in SignalNamer.instance.dirMap.keys) {
        currentExcel = SignalNamer.instance.exportToXLSX(
            result,
            file.split("/").last.split(".").first,
            SignalNamer.instance.dirMap[file]!,
            false,
            true,
            currentExcel,
            (i == SignalNamer.instance.dirMap.length - 1));
        i++;
      }
    } else {
      // print(result.split("//").last.split("."));
      SignalNamer.instance.exportToXLSX(
          result,
          result.split("//").last.split(".").first,
          SignalNamer.instance.foundSignals,
          true,
          false,
          null,
          true);
    }

    showAlertDialog(
        context, "Export Successful", "Successfully exported to Excel");
  } else {
    return;
  }
}

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../alert.dart';
import '../models/Signal.dart';
import '../signalNamer.dart';

getDir() async {
  String? result = await FilePicker.platform.getDirectoryPath(
    dialogTitle: "Pick a directory",
  );
  if (result == null) {
    return;
  }
  return result;
}

getExcDir() async {
  String? result = await FilePicker.platform.getDirectoryPath(
    dialogTitle: "Pick a directory to exclude",
  );
  if (result == null) {
    return;
  }
  return result;
}

Future<String?> getFile(type) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: "Pick a $type file",
    allowMultiple: false,
  );
  dynamic? filename = "";
  if (kIsWeb) {
    // print("Web detected, trying to get path from bytes.");
    // print(result);
    // filename = result?.files.first.bytes;
    // THIS IS BROKEN :( :( :( :(
  } else {
    filename = result?.paths.first!;
  }

  print("Filepath: $filename");
  return filename;
}

void fromVerilog(callbackFunc) async {
  String? filename = await getFile("Verilog");
  if (filename != null) {
    SignalNamer.instance.findFromFile(filename, fromWeb: kIsWeb);
    // int i = 0;
    callbackFunc();
  }
}

void fromExcel(callbackFunc) async {
  String? filename = await getFile("Excel");
  if (filename != null) {
    SignalNamer.instance.findFromXLSX(filename);
    // int i = 0;
    callbackFunc();
  }
}

void saveToExcel(BuildContext context) async {
  String? result = await FilePicker.platform.saveFile();
  if (result != null) {
    if (SignalNamer.instance.mapMode) {
      Excel? currentExcel = null;
      int i = 0;
      for (String file in SignalNamer.instance.signalMap.keys) {
        currentExcel = SignalNamer.instance.exportToXLSX(
            result,
            file.split("/").last.split(".").first,
            SignalNamer.instance.signalMap[file]!,
            false,
            true,
            currentExcel,
            (i == SignalNamer.instance.signalMap.length - 1));
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

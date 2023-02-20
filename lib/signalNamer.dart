import 'dart:io';
import 'package:event_listener/event_listener.dart';
import 'package:excel/excel.dart';
import 'package:signal_namer_dart/utils/fileUtils.dart';

import 'components/logManager.dart';
import 'models/Error.dart';
import 'models/Signal.dart';

// void main(List<String> args) {
//   print("hello world!");
//   SignalNamer signalNamer = SignalNamer();
//   signalNamer.findFromFile("/home/zackery/signalNamer/wishbone_controller.v");
//   print("Final signals:");
//   for (Signal signal in signalNamer.foundSignals) {
//     print("$signal");
//   }
//   signalNamer.exportToCSV("output.csv");
// }

const commentStyle = "//";

class SignalNamer {
  static final SignalNamer instance = SignalNamer._privateConstructor();
  SignalNamer._privateConstructor();
  List<String> dictionary = ["input", "output", "wire", "reg", "output reg"];
  List<String> excludeList = [];
  List<Signal> foundSignals = [];
  int failures = 0;
  bool mapMode = false;
  bool excelMode = false;
  List<ErrorObj> errors = [];
  Map<String, List<Signal>> signalMap = Map();
  Map<String, List<Signal>> loadedProject = Map();
  bool projectLoaded = false;
  int totalSignals = 0;
  //Swap Excel from being loaded in DIR mode to being loaded in project mode
  swapToProjectMode() {
    excelMode = false;
    projectLoaded = true;
    loadedProject = Map.from(signalMap);
    signalMap = Map();
    mapMode = false;
  }

  findFromFile(dynamic filePath, {bool fromWeb = false}) {
    var openFile;
    if (fromWeb) {
      // print("Attempting File.fromRaw");
      // openFile = File()
      print("Web does  not work");
    } else {
      openFile = File(filePath);
    }
    List<String> lines = [];
    lines = openFile.readAsLinesSync();

    List<dynamic>? fs = findSignals(lines, filePath.split("/").last);

    if (fs != [] && fs != null) {
      foundSignals = List.castFrom(fs);
    }
  }

  List<String> signalListToString(List<Signal> signals) {
    List<String> rtn = [];
    for (Signal signal in signals) {
      rtn.add(signal.toString());
    }
    return rtn;
  }

  addExcludeDir(String toAdd) {
    excludeList.add(toAdd);
  }

  findFromXLSX(String filePath) {
    var openFile = File(filePath);
    excelMode = true;
    var bytes = openFile.readAsBytesSync();
    Excel excel = Excel.decodeBytes(bytes);
    // stdout.write("Done!\n");
    LogManager.instance.addLog(
        "=============================================================");
    LogManager.instance.addLog("Note: XLSX read runs in directory mode");
    errors.add(ErrorObj(
        content: "NOTE: Loading from XLSX runs in directory mode",
        line: -1,
        fileName: "System",
        fullLine: "N/A",
        type: "Notice"));
    LogManager.instance.addLog("Loading Signals...\n");
    mapMode = true;
    signalMap.clear();
    int totalSignals = 0;
    for (String sheet in excel.sheets.keys) {
      String tmpLog = "";

      if (sheet == "NOTE") {
        continue;
      }
      tmpLog += "    $sheet";
      stdout.write("    $sheet");
      String signalString = "Placeholder!!!!!!!";
      int columns = 0;
      List<String> avalibleProperties = [];
      while (signalString != "") {
        String? res = excel[sheet]
            .cell(CellIndex.indexByColumnRow(columnIndex: columns, rowIndex: 0))
            .value;

        if (res != null) {
          signalString = res;
          avalibleProperties.add(signalString);
        } else {
          break;
        }
        columns++;
      }
      signalMap[sheet] = [];
      // Signal Name	Bit Length	Is Bus	Signal Type	From File	Line Number	Comment
      int row = 1;
      int column = 0;
      int signals = 0;
      bool breakout = false;

      while (!breakout) {
        Signal currentSignal = Signal.type(SignalType.unknown);
        column = 0;
        for (String property in avalibleProperties) {
          var res = excel[sheet]
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: column, rowIndex: row))
              .value;
          if (res == null) {
            breakout = true;
            break;
          }
          if (property.toLowerCase() == "signal name") {
            // print("Signal name: $res");
            signals++;
            totalSignals++;
            currentSignal.signalName = res;
          } else if (property.toLowerCase() == "bit length") {
            currentSignal.bitLength = res;
            // print("Big length ${res}");
          } else if (property.toLowerCase() == "is bus") {
            if (res == "Yes") {
              currentSignal.isBus = true;
            } else {
              currentSignal.isBus = false;
            }
            // print("Is bus ${res}");
          } else if (property.toLowerCase() == "signal type") {
            currentSignal.signalType = getTypeFromString(res);
            // print("Type ${res}");
          } else if (property.toLowerCase() == "from file") {
            // print("file ${res}");
            currentSignal.fileName = res;
          } else if (property.toLowerCase() == "line number") {
            // print("line ${res}");
            currentSignal.lineNumb = res;
          } else if (property.toLowerCase() == "comment") {
            // print("comment ${res}");
            currentSignal.comment = res;
          } else {
            // print("Unknown: $property: $res");
          }
          column++;
        }
        if (!breakout) {
          signals++;
          // totalSignals++;
          stdout.write(".");
          tmpLog += ".";

          signalMap[sheet]?.add(currentSignal);
          row++;
        }
      }
      LogManager.instance.addLog(tmpLog + "DONE (found $signals)");

      // stdout.write("DONE (found $signals)\n");
    }
    // for (String sheet in dirMap.keys) {
    //   stdout.write("$sheet");
    //   int x = 0;
    //   for (Signal signal in dirMap[sheet]!) {
    //     stdout.write(".");
    //     x++;
    //   }
    //   stdout.write("DONE (Found $x signals)\n");
    //   totalSignals = totalSignals + x;
    // }
    // print("Done, found $totalSignals total");
    LogManager.instance.addLog(
        "All Signals loaded! Found $totalSignals from ${excel.sheets.length - 1} 'files'");
    LogManager.instance.addLog(
        "=============================================================");
  }

  SignalType getTypeFromString(String typeString) {
    List<SignalType> values = SignalType.values;
    for (SignalType value in values) {
      String shortName = value.toString().split(".").last;

      if (typeString.contains(shortName)) {
        if (typeString.contains("output") && typeString.contains("reg")) {
          return SignalType.outputReg;
        } else {
          return value;
        }
      }
    }
    return SignalType.notSignal;
  }

  Signal findMatch(String line) {
    for (String type in dictionary) {
      if (line.contains(type)) {
        if (line.contains("output") && line.contains("reg")) {
          return Signal.withRawLine(SignalType.outputReg, line);
        } else {
          if (!line.contains("localparam")) {
            return Signal.withRawLine(getTypeFromString(type), line);
          }
        }
      }
    }
    return Signal.type(SignalType.notSignal);
  }

  bool isMatch(String line) {
    return findMatch(line).signalType != SignalType.notSignal;
  }

  bool checkIsCommented(String line) {
    if (!line.contains(commentStyle)) {
      return false;
    }
    List<String> splitLine = line.split(commentStyle);
    if (splitLine.first == commentStyle || splitLine.first == "") {
      return true;
    }
    // print(splitLine);
    if (isMatch(splitLine.first)) {
      return false;
    }
    return false;
  }

  findSignals(List<String> lines, String currentFile) {
    //print("Starting Phase 1 (Identify possible signals)");
    List<Signal> pass1 = [];
    int lineNumb = 0;
    for (String line in lines) {
      Signal returnedSignal = findMatch(line);
      if (returnedSignal.signalType != SignalType.notSignal) {
        returnedSignal.fileName = currentFile;
        returnedSignal.lineNumb = lineNumb;
        pass1.add(returnedSignal);
        // print("Found Signal: ${returnedSignal.toString()}");
      }
      lineNumb++;
    }
    LogManager.instance
        .addLog("Phase 1 complete, found: ${pass1.length} notable signals");
    if (pass1.length == 0) {
      errors.add(ErrorObj(
          content: "No signals found in file (Or empty file)",
          line: -1,
          fileName: currentFile,
          fullLine: "N/A",
          type: "no signals"));
      failures++;
      LogManager.instance
          .addLog("No signals found. Please verify you have the correct file");
      return [];
    }
    LogManager.instance
        .addLog("Starting Phase 2 (Filter out commented signals)");
    List<Signal> pass2 = [];
    for (Signal currentSignal in pass1) {
      if (!checkIsCommented(currentSignal.rawLine)) {
        pass2.add(currentSignal);
      } else {
        // print("Ignoring ${currentSignal.rawLine}");
      }
    }
    LogManager.instance
        .addLog("Phase 2 complete, found ${pass2.length} uncommented signals");
    if (pass2.length == 0) {
      LogManager.instance.addLog(
          "No uncommented signals found. Please make sure you have valid signals in your file.");
      errors.add(ErrorObj(
          content: "No uncommented signals found in file (Or empty file)",
          line: -1,
          fileName: currentFile,
          fullLine: "N/A",
          type: "no uncommented signals"));
      failures++;
      return;
    }
    LogManager.instance.addLog(
        "Starting Phase 3 (Finding multiple signals in a line and find Names ");
    List<Signal> pass3 = [];
    for (Signal currentSignal in pass2) {
      String workingLine = currentSignal.rawLine;
      workingLine = workingLine.replaceAll(' ', '');
      workingLine = workingLine.replaceAll(";", "");
      List<String> splitLine = workingLine.split(",");
      // splitLine = splitLine.last.split(commentStyle);

      // print("original $workingLine split: $splitLine");
      bool busChain = false;
      int bl = 0;
      for (String signalName in splitLine) {
        // print("Name: $signalName");
        if (signalName != "" && signalName != " ") {
          if (checkIsCommented(signalName)) {
            break;
          }
          if (currentSignal.signalType == SignalType.input) {
            signalName = signalName.split("input").last;
          } else if (currentSignal.signalType == SignalType.output) {
            signalName = signalName.split("output").last;
          } else if (currentSignal.signalType == SignalType.reg) {
            signalName = signalName.split("reg").last;
          } else if (currentSignal.signalType == SignalType.wire) {
            signalName = signalName.split("wire").last;
          } else if (currentSignal.signalType == SignalType.outputReg) {
            signalName = signalName.split("outputreg").last;
          }
          Signal newSig = currentSignal.cloneMyself();

          List<String> splitName = signalName.split("]");
          // print("Splitname = $splitName");
          if (splitName.length == 1) {
            if (busChain == true) {
              newSig.bitLength = bl;
              newSig.isBus = true;
            } else {
              newSig.isBus = false;
            }
          } else {
            // print("splitName: ${splitName}");
            signalName = splitName.last;
            if (signalName.contains(commentStyle)) {
              signalName = signalName.split(commentStyle).first;
            }
            String busString = splitName.first.replaceAll("[", "");
            List<String> busStringsplit = busString.split(":");
            try {
              int numberFirst = int.parse(busStringsplit.first);
              int numberLast = int.parse(busStringsplit.last);
              bl = (numberLast - numberFirst).abs() + 1;
            } on FormatException {
              // LogManager.instance
              //     .addLog("Unhandled: This tool can't do params yet");
              newSig.comment =
                  "FIXME: Either invalid signal or unable to determine bus length";
              errors.add(ErrorObj(
                  content: "Unhandled parameter or invalid signal",
                  line: currentSignal.lineNumb,
                  fileName: currentSignal.fileName,
                  fullLine: currentSignal.rawLine,
                  type: "unimplemented parameter"));
              failures++;
            }
            newSig.bitLength = bl;
            newSig.isBus = true;
            busChain = true;
            // print("Calculated bitlength = $bitLength");
          }
          newSig.signalName = signalName;
          // print("Found signal: $signalName");
          pass3.add(newSig);
        }
      }
    }
    LogManager.instance
        .addLog("Phase 3 complete. Found ${pass3.length} signals");
    LogManager.instance.addLog("Starting Phase 4 (Parsing comments)");
    List<Signal> pass4 = parseComments(pass3);
    LogManager.instance.addLog("Phase 4 completed.");
    LogManager.instance
        .addLog("Done $failures possible failures / incomplete signals");
    return pass4;
  }

  List<Signal> parseComments(List<Signal> signals) {
    for (Signal signal in signals) {
      List<String> splitLine = signal.rawLine.split(commentStyle);
      // print("Line:$splitLine");
      if (signal.comment == "") {
        if (splitLine.length == 1) {
          signal.comment = "";
        } else {
          // print("comment was: ${splitLine.last}");
          signal.comment = splitLine.last;
        }
      }
    }
    return signals;
  }

  exportToCSV(String filename) {
    var openFile = File(filename).openWrite();
    // return '"$signalName","$bitLength","$isBus","$signalType","$fileName","$lineNumb","$comment"';

    openFile.write(
        '"Signal Name","Bit Length","Is Bus?","Signal Type","From File","Line Number","Comment"\n');
    for (Signal signal in foundSignals) {
      openFile.write(signal.toCSVLine() + "\n");
    }
  }

  String? directoryFind(String name) {
    var Dir = Directory(name);

    mapMode = true;
    try {
      for (var entity in Dir.listSync(recursive: true)) {
        if (entity.path.split(".").last == "v") {
          LogManager.instance.addLog(
              "=============================================================");
          LogManager.instance.addLog("Processing: ${entity.path}");
          findFromFile(entity.path);
          signalMap[entity.path] = foundSignals;
        }
      }
    } on FileSystemException catch (err) {
      return err.osError!.message;
    }
    LogManager.instance.addLog("Done!\n");
    // LogManager.instance.eventListener.emit("LogDone", "from directory find");
  }

  Excel exportToXLSX(String filename, String sheet, List<Signal> signals,
      bool includeRaw, bool isDir, Excel? existing, bool last) {
    // if (!File(filename).existsSync()) {
    //   print("Creating file");
    //   File(filename).createSync();
    //   if (!File(filename).existsSync()) {
    //     print("Failed to create file!");
    //   }
    // }
    // var bytes = File(filename).readAsBytesSync();

    Excel decoder;
    if (File(filename).existsSync()) {
      if (existing != null) {
        decoder = existing;
        LogManager.instance.addLog("Using existing Excel instance");
      } else {
        decoder = Excel.createExcel();
      }
    } else {
      LogManager.instance.addLog("Creating $filename for signal $sheet");
      decoder = Excel.createExcel();
    }
    if (decoder.sheets.containsKey(sheet)) {
      LogManager.instance.addLog("Skipping duplicate sheet");
    } else {
      Sheet sheetObject = decoder[sheet];

      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = "Signal Name";
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = "Bit Length";
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = "Is Bus";
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = "Signal Type";
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = "From File";
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
          .value = "Line Number";
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
          .value = "Comment";

      for (int i = 0; i < signals.length; i++) {
        Signal signal = signals[i];
        LogManager.instance.addLog("Writing signal: $signal");
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
            .value = signal.signalName;
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
            .value = signal.bitLength;
        if (signal.isBus) {
          sheetObject
              .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
              .value = "Yes";
        } else {
          sheetObject
              .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
              .value = "No";
        }
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
            .value = signal.signalType.name;
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
            .value = signal.fileName;
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
            .value = signal.lineNumb;
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1))
            .value = signal.comment;
      }
      if (includeRaw) {
        Sheet RAWSheet = decoder["${sheet}_withRAWLine"];
        RAWSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
            .value = "Signal Name";

        RAWSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
            .value = "Line Number";
        RAWSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
            .value = "Comment";
        RAWSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
            .value = "Raw Line Data";
        for (int i = 0; i < signals.length; i++) {
          Signal signal = signals[i];

          RAWSheet.cell(
                  CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
              .value = signal.signalName;

          RAWSheet.cell(
                  CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
              .value = signal.lineNumb;
          RAWSheet.cell(
                  CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
              .value = signal.comment;
          RAWSheet.cell(
                  CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
              .value = signal.rawLine;
        }
      }
    }
    if (last) {
      // This is a work-around because the Excel library (at 2.0.1) throws an exception while opening an existing file
      decoder["NOTE"]
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
              .value =
          "NOTE: This file was automatically generated by the signal namer application. There may be missing or incorrect data.";

      LogManager.instance.addLog("Last time, exporting");

      var fileBytes = decoder.save(fileName: filename);
      File(filename)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);
      LogManager.instance.addLog("Wrote $filename");
    }

    return decoder;
  }

  fileDiff() {}
}

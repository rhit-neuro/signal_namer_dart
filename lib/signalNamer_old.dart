import 'dart:io';
import 'dart:ui';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

void main(List<String> args) {
  print("hello world!");
  SignalNamer signalNamer = SignalNamer();
  signalNamer.findFromFile("/home/zackery/signalNamer/wishbone_controller.v");
  print("Final signals:");
  for (Signal signal in signalNamer.foundSignals) {
    print("$signal");
  }
  signalNamer.exportToCSV("output.csv");
}

enum SignalType {
  input,
  output,
  wire,
  reg,
  outputReg,
  unknown,
  notSignal,
}

const commentStyle = "//";

class Signal {
  String signalName = "Unknown";
  int bitLength = 1;
  bool isBus = false;
  SignalType signalType = SignalType.unknown;
  String rawLine = "Unknown";
  int lineNumb = -1;
  String fileName = "Unknown";
  String comment = "";
  int storedAt = 0;
  Signal(String signalName, int bitLength, bool isBus, SignalType type,
      String rawLine, int lineNumb, String fileName) {
    this.signalName = signalName;
    this.bitLength = bitLength;
    this.isBus = isBus;
    signalType = type;
    this.rawLine = rawLine;
    this.lineNumb = lineNumb;
    this.fileName = fileName;
  }

  Signal.type(SignalType type) {
    signalType = type;
  }
  Signal.withRawLine(SignalType type, String rl) {
    signalType = type;
    rawLine = rl;
  }
  @override
  String toString() {
    return "signalName = $signalName, bitLength = $bitLength, isBus=$isBus, signalType = ${signalType.name}, lineNumb = $lineNumb, fileName = $fileName,comment=$comment";
  }

  Signal cloneMyself() {
    return Signal(
        signalName, bitLength, isBus, signalType, rawLine, lineNumb, fileName);
  }

  String toCSVLine() {
    return '"$signalName","$bitLength","$isBus","${signalType.name}","$fileName","$lineNumb","$comment"';
  }
}

class SignalNamer {
  List<String> dictionary = ["input", "output", "wire", "reg", "output reg"];

  List<Signal> foundSignals = [];
  int failures = 0;
  bool dirMode = false;
  Map<String, List<Signal>> dirMap = Map();
  findFromFile(String filePath) {
    var openFile = File(filePath);
    List<String> lines = [];
    lines = openFile.readAsLinesSync();

    List<Signal> fs = findSignals(lines, filePath.split("/").last);
    if (fs != [] && fs != Null) {
      foundSignals = fs;
    }
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
          return Signal.withRawLine(getTypeFromString(type), line);
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
    print("Starting Phase 1 (Identify possible signals)");
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
    print("Phase 1 complete, found: ${pass1.length} notable signals");
    if (pass1.length == 0) {
      print("No signals found. Please verify you have the correct file");
      return [];
    }
    print("Starting Phase 2 (Filter out commented signals)");
    List<Signal> pass2 = [];
    for (Signal currentSignal in pass1) {
      if (!checkIsCommented(currentSignal.rawLine)) {
        pass2.add(currentSignal);
      } else {
        // print("Ignoring ${currentSignal.rawLine}");
      }
    }
    print("Phase 2 complete, found ${pass2.length} uncommented signals");
    if (pass2.length == 0) {
      print(
          "No uncommented signals found. Please make sure you have valid signals in your file.");
      return;
    }
    print(
        "Starting Phase 3 (Finding multiple signals in a line and find Names ");
    List<Signal> pass3 = [];
    for (Signal currentSignal in pass2) {
      String workingLine = currentSignal.rawLine;
      workingLine = workingLine.replaceAll(' ', '');
      workingLine = workingLine.replaceAll(";", "");
      List<String> splitLine = workingLine.split(",");

      // print("original $workingLine split: $splitLine");
      bool busChain = false;
      int bl = 0;
      for (String signalName in splitLine) {
        print(signalName);
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
            signalName = splitName.last;
            String busString = splitName.first.replaceAll("[", "");
            List<String> busStringsplit = busString.split(":");
            try {
              int numberFirst = int.parse(busStringsplit.first);
              int numberLast = int.parse(busStringsplit.last);
              bl = (numberLast - numberFirst).abs() + 1;
            } on FormatException {
              print("Unhandled: This tool can't do params yet");
              newSig.comment =
                  "FIXME: Either invalid signal or unable to determine bus length";
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
    print("Phase 3 complete. Found ${pass3.length} signals");
    print("Starting Phase 4 (Parsing comments)");
    List<Signal> pass4 = parseComments(pass3);
    print("Phase 4 completed.");
    print("Done $failures possible failures / incomplete signals");
    return pass4;
  }

  List<Signal> parseComments(List<Signal> signals) {
    for (Signal signal in signals) {
      List<String> splitLine = signal.rawLine.split(commentStyle);
      if (signal.comment == "") {
        if (splitLine.length == 1) {
          signal.comment = "";
        } else {
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

  void directoryFind(String name) {
    var Dir = Directory(name);

    dirMode = true;
    for (var entity in Dir.listSync(recursive: true)) {
      if (entity.path.split(".").last == "v") {
        print("Processing: ${entity.path}");
        findFromFile(entity.path);
        dirMap[entity.path] = foundSignals;
      }
    }
    print("Done");
  }

  Excel exportToXLS(String filename, String sheet, List<Signal> signals,
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
        print("Using existing Excel instance");
      } else {
        decoder = Excel.createExcel();
      }
    } else {
      print("Creating $filename for signal $sheet");
      decoder = Excel.createExcel();
    }
    if (decoder.sheets.containsKey(sheet)) {
      print("Skipping duplicate sheet");
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
        print("Writing signal: $signal");
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
      print("Last time, exporting");
      if (kIsWeb) {
        decoder.save(fileName: filename);
      } else {
        var fileBytes = decoder.save(fileName: filename);
        File(filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes!);
        print("Wrote $filename");
      }
    }
    return decoder;
  }
}

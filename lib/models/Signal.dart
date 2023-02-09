enum SignalType {
  input,
  output,
  wire,
  reg,
  outputReg,
  unknown,
  notSignal,
}

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
  Signal(this.signalName, this.bitLength, this.isBus, this.signalType,
      this.rawLine, this.lineNumb, this.fileName);

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

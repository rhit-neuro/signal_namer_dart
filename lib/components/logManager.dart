import 'package:event_listener/event_listener.dart';

class LogManager {
  static final LogManager instance = LogManager._privateConstructor();
  LogManager._privateConstructor();
  var eventListener = new EventListener();

  List<String> logs = [];
  addLog(log) {
    logs.add(log);
    print(log);
    // LogManager.instance.eventListener.emit("addedLog", "from logManager");
  }
}

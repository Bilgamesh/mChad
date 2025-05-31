class LoggingUtil {
  LoggingUtil({this.module});
  final String? module;

  void log(String type, String text) {
    if (module == null) {
      print('[${DateTime.now().toString()}][$type] $text');
    } else {
      print('[${DateTime.now().toString()}][$module][$type] $text');
    }
  }

  void info(String text) {
    log('INFO', text);
  }

  void error(String text) {
    log('ERROR', text);
  }
}

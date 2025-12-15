import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

final logs = <String>[];

class _LoggerOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      print(line);
      logs.add(line);
    }
    print('');
    logs.add('');
  }
}

class _LoggerFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

final logger = Logger(
  filter: _LoggerFilter(),
  output: _LoggerOutput(),
  printer: PrettyPrinter(
    noBoxingByDefault: true,
    printTime: true,
    colors: false,
    lineLength: 200,
  ),
);

void copyLogsToClipboard() {
  logger.d('Copying logs to clipboard');
  final text = logs.join('\n');
  Clipboard.setData(ClipboardData(text: text));
}

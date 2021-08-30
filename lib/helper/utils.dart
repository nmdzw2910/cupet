import 'package:logger/logger.dart';

var _logger = Logger(
  printer: PrettyPrinter(
    colors: true,
    printEmojis: true,
  ),
);
console(msg) {
  _logger.d(msg);
}

warn(msg) {
  _logger.w(msg);
}

error(msg) {
  _logger.e(msg);
}

String removeLastCharacter(String str) {
  String result = null;
  if ((str != null) && (str.length > 0)) {
    result = str.substring(0, str.length - 3);
  }

  return result;
}

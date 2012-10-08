library sprintf;

import 'dart:math';

part 'src/formatters/Formatter.dart';
part 'src/formatters/int_formatter.dart';
part 'src/formatters/float_formatter.dart';
part 'src/formatters/string_formatter.dart';
part 'src/sprintf_impl.dart';

typedef SPrintF(String fmt, var args);

var _printer = new PrintFormat();

String sprintf(String fmt, var args) {
  return _printer.call(fmt, args);
}

part of sprintf;

typedef PrintFormatFormatter = Formatter Function(dynamic arg, dynamic options);
//typedef Formatter PrintFormatFormatter(arg, options);

class PrintFormat {
  static final RegExp specifier = RegExp(
      r'%(?:(\d+)\$)?([\+\-\#0 ]*)(\d+|\*)?(?:\.(\d+|\*))?([a-z%])',
      caseSensitive: false);
  static final RegExp uppercase_rx = RegExp(r'[A-Z]', caseSensitive: true);

  final Map<String, PrintFormatFormatter> _formatters = {
    'i': (arg, options) => IntFormatter(arg, 'i', options),
    'd': (arg, options) => IntFormatter(arg, 'd', options),
    'x': (arg, options) => IntFormatter(arg, 'x', options),
    'X': (arg, options) => IntFormatter(arg, 'x', options),
    'o': (arg, options) => IntFormatter(arg, 'o', options),
    'O': (arg, options) => IntFormatter(arg, 'o', options),
    'e': (arg, options) => FloatFormatter(arg, 'e', options),
    'E': (arg, options) => FloatFormatter(arg, 'e', options),
    'f': (arg, options) => FloatFormatter(arg, 'f', options),
    'F': (arg, options) => FloatFormatter(arg, 'f', options),
    'g': (arg, options) => FloatFormatter(arg, 'g', options),
    'G': (arg, options) => FloatFormatter(arg, 'g', options),
    's': (arg, options) => StringFormatter(arg, 's', options),
  };

  String call(String fmt, var args) {
    var ret = '';

    var offset = 0;
    var arg_offset = 0;

    if (args is! List) {
      throw ArgumentError('Expecting list as second argument');
    }

    for (var m in specifier.allMatches(fmt)) {
      var _parameter = m[1];
      var _flags = m[2]!;
      var _width = m[3];
      var _precision = m[4];
      var _type = m[5]!;

      var _arg_str = '';
      var _options = {
        'is_upper': false,
        'width': -1,
        'precision': -1,
        'length': -1,
        'radix': 10,
        'sign': '',
        'specifier_type': _type,
      };

      _parse_flags(_flags).forEach((var k, var v) {
        _options[k] = v;
      });

      // The argument we want to deal with
      var _arg = _parameter == null ? null : args[int.parse(_parameter) - 1];

      // parse width
      if (_width != null) {
        _options['width'] =
            (_width == '*' ? args[arg_offset++] : int.parse(_width));
      }

      // parse precision
      if (_precision != null) {
        _options['precision'] =
            (_precision == '*' ? args[arg_offset++] : int.parse(_precision));
      }

      // grab the argument we'll be dealing with
      if (_arg == null && _type != '%') {
        _arg = args[arg_offset++];
      }

      _options['is_upper'] = uppercase_rx.hasMatch(_type);

      if (_type == '%') {
        if (_flags.isNotEmpty || _width != null || _precision != null) {
          throw Exception('"%" does not take any flags');
        }
        _arg_str = '%';
      } else if (_formatters.containsKey(_type)) {
        _arg_str = _formatters[_type]!(_arg, _options).asString();
      } else {
        throw ArgumentError('Unknown format type ${_type}');
      }

      // Add the pre-format string to the return
      ret += fmt.substring(offset, m.start);
      offset = m.end;

      ret += _arg_str;
    }

    return ret += fmt.substring(offset);
  }

  void register_specifier(String specifier, PrintFormatFormatter formatter) {
    _formatters[specifier] = formatter;
  }

  void unregistier_specifier(String specifier) {
    _formatters.remove(specifier);
  }

  Map _parse_flags(String flags) {
    return {
      'sign': flags.contains('+') ? '+' : '',
      'padding_char': flags.contains('0') ? '0' : ' ',
      'add_space': flags.contains(' '),
      'left_align': flags.contains('-'),
      'alternate_form': flags.contains('#'),
    };
  }
}

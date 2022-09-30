part of sprintf;

class FloatFormatter extends Formatter {
  // ignore: todo
  // TODO: can't rely on '.' being the decimal separator
  static final _number_rx = RegExp(r'^[\-\+]?(\d+)\.(\d+)$');
  static final _expo_rx = RegExp(r'^[\-\+]?(\d)\.(\d+)e([\-\+]?\d+)$');
  static final _leading_zeroes_rx = RegExp(r'^(0*)[1-9]+');

  double _arg;
  final List<int> _digits = [];
  int _exponent = 0;
  int _decimal = 0;
  bool _is_negative = false;
  bool _has_init = false;
  String? _output;

  FloatFormatter(this._arg, var fmt_type, var options)
      : super(fmt_type, options) {
    if (_arg.isNaN) {
      _has_init = true;
      return;
    }

    if (_arg.isInfinite) {
      _is_negative = _arg.isNegative;
      _has_init = true;
      return;
    }

    _arg = _arg.toDouble();

    if (_arg < 0) {
      _is_negative = true;
      _arg = -_arg;
    }

    var arg_str =
        _arg == _arg.truncate() ? _arg.toStringAsFixed(1) : _arg.toString();

    var m1 = _number_rx.firstMatch(arg_str);
    if (m1 != null) {
      var int_part = m1.group(1)!;
      var fraction = m1.group(2)!;

      /*
       * Cases:
       * 1.2345    = 1.2345e0  -> [12345]    e+0 d1  l5
       * 123.45    = 1.2345e2  -> [12345]    e+2 d3  l5
       * 0.12345   = 1.2345e-1 -> [012345]   e-1 d1  l6
       * 0.0012345 = 1.2345e-3 -> [00012345] e-3 d1  l8
       */

      _decimal = int_part.length;
      _digits.addAll(int_part.split('').map(int.parse));
      _digits.addAll(fraction.split('').map(int.parse));

      if (int_part.length == 1) {
        if (int_part == '0') {
          var leading_zeroes_match = _leading_zeroes_rx.firstMatch(fraction);

          if (leading_zeroes_match != null) {
            var zeroes_count = leading_zeroes_match.group(1)!.length;
            // print("zeroes_count=${zeroes_count}");
            _exponent =
                zeroes_count > 0 ? -(zeroes_count + 1) : zeroes_count - 1;
          } else {
            _exponent = 0;
          }
        } // else int_part != 0
        else {
          _exponent = 0;
        }
      } else {
        _exponent = int_part.length - 1;
      }
    } else {
      var m2 = _expo_rx.firstMatch(arg_str);
      if (m2 != null) {
        var int_part = m2.group(1)!;
        var fraction = m2.group(2)!;
        _exponent = int.parse(m2.group(3)!);

        if (_exponent > 0) {
          var diff = _exponent - fraction.length + 1;
          _decimal = _exponent + 1;
          _digits.addAll(int_part.split('').map(int.parse));
          _digits.addAll(fraction.split('').map(int.parse));
          _digits.addAll(
              Formatter.get_padding(diff, '0').split('').map(int.parse));
        } else {
          var diff = int_part.length - _exponent - 1;
          _decimal = int_part.length;
          _digits.addAll(
              Formatter.get_padding(diff, '0').split('').map(int.parse));
          _digits.addAll(int_part.split('').map(int.parse));
          _digits.addAll(fraction.split('').map(int.parse));
        }
      } // else something wrong
    }
    _has_init = true;
    //print("arg_str=${arg_str}");
    //print("decimal=${_decimal}, exp=${_exponent}, digits=${_digits}");
  }

  @override
  String asString() {
    var ret = '';

    if (!_has_init) {
      return ret;
    }

    if (_output != null) {
      return _output!;
    }

    if (options['add_space'] && options['sign'] == '' && _arg >= 0) {
      options['sign'] = ' ';
    }

    if (_arg.isInfinite) {
      if (_arg.isNegative) {
        options['sign'] = '-';
      }

      ret = 'inf';
      options['padding_char'] = ' ';
    }

    if (_arg.isNaN) {
      ret = 'nan';
      options['padding_char'] = ' ';
    }

    if (options['precision'] == -1) {
      // ignore: todo
      options['precision'] = 6; // TODO: make this configurable
    } else if (fmt_type == 'g' && options['precision'] == 0) {
      options['precision'] = 1;
    }

    if (_is_negative) {
      options['sign'] = '-';
    }

    if (!(_arg.isInfinite || _arg.isNaN)) {
      if (fmt_type == 'e') {
        ret = asExponential(options['precision'], remove_trailing_zeros: false);
      } else if (fmt_type == 'f') {
        ret = asFixed(options['precision'], remove_trailing_zeros: false);
      } else {
        // type == g
        var _exp = _exponent;
        var sig_digs = options['precision'];
        // print("${_exp} ${sig_digs}");
        if (-4 <= _exp && _exp < options['precision']) {
          sig_digs -= _decimal;
          var precision = max<num>(options['precision'] - 1 - _exp, sig_digs);

          ret = asFixed(precision.toInt(),
              remove_trailing_zeros: !options['alternate_form']);
        } else {
          ret = asExponential(options['precision'] - 1,
              remove_trailing_zeros: !options['alternate_form']);
        }
      }
    }

    var min_chars = options['width'];
    var str_len = ret.length + options['sign'].length;
    var padding = '';

    if (min_chars > str_len) {
      if (options['padding_char'] == '0' && !options['left_align']) {
        padding = Formatter.get_padding(min_chars - str_len, '0');
      } else {
        padding = Formatter.get_padding(min_chars - str_len, ' ');
      }
    }

    if (options['left_align']) {
      ret = "${options['sign']}${ret}${padding}";
    } else if (options['padding_char'] == '0') {
      ret = "${options['sign']}${padding}${ret}";
    } else {
      ret = "${padding}${options['sign']}${ret}";
    }

    if (options['is_upper']) {
      ret = ret.toUpperCase();
    }

    return (_output = ret);
  }

  String asFixed(int precision, {bool remove_trailing_zeros = true}) {
    // precision is the number of decimal places after the decimal point to keep
    var offset = _decimal + precision - 1;
    var extra_zeroes = precision - (_digits.length - offset);

    if (extra_zeroes > 0) {
      _digits.addAll(
          Formatter.get_padding(extra_zeroes, '0').split('').map(int.parse));
    }

    _round(offset + 1, offset);

    var ret = _digits.sublist(0, _decimal).fold('', (i, e) => '${i}${e}');
    var trailing_digits = _digits.sublist(_decimal, _decimal + precision);
    if (remove_trailing_zeros) {
      trailing_digits = _remove_trailing_zeros(trailing_digits);
    }
    var trailing_zeroes = trailing_digits.fold('', (i, e) => '${i}${e}');
    if (trailing_zeroes.isEmpty) {
      return ret;
    }
    ret = '${ret}.${trailing_zeroes}';

    return ret;
  }

  String asExponential(int precision, {bool remove_trailing_zeros = true}) {
    var offset = _decimal - _exponent;

    var extra_zeroes = precision - (_digits.length - offset) + 1;

    if (extra_zeroes > 0) {
      _digits.addAll(
          Formatter.get_padding(extra_zeroes, '0').split('').map(int.parse));
    }

    _round(offset + precision, offset);

    var ret = _digits[offset - 1].toString();
    //print ("(${offset}, ${precision})${_digits}");
    var trailing_digits = _digits.sublist(offset, offset + precision);
    // print ("trailing_digits=${trailing_digits}");
    var _exp_str = _exponent.abs().toString();

    if (_exponent < 10 && _exponent > -10) {
      _exp_str = '0${_exp_str}';
    }

    _exp_str = (_exponent < 0) ? 'e-${_exp_str}' : 'e+${_exp_str}';

    if (remove_trailing_zeros) {
      trailing_digits = _remove_trailing_zeros(trailing_digits);
    }

    if (trailing_digits.isNotEmpty) {
      ret += '.';
    }

    ret = trailing_digits.fold(ret, (i, e) => '${i}${e}');
    ret = '${ret}${_exp_str}';

    return ret;
  }

  List<int> _remove_trailing_zeros(List<int> trailing_digits) {
    var nzeroes = 0;
    for (var i = trailing_digits.length - 1; i >= 0; i--) {
      if (trailing_digits[i] == 0) {
        nzeroes++;
      } else {
        break;
      }
    }
    return trailing_digits.sublist(0, trailing_digits.length - nzeroes);
  }

  /*
	rounding_offset: Where to start rounding from
	offset: where to end rounding
	 */
  void _round(var rounding_offset, var offset) {
    var carry = 0;

    if (rounding_offset >= _digits.length) {
      return;
    }
    // Round the digit after the precision
    var d = _digits[rounding_offset];
    carry = d >= 5 ? 1 : 0;
    _digits[rounding_offset] = d % 10;
    rounding_offset -= 1;

    //propagate the carry
    while (carry > 0) {
      d = _digits[rounding_offset] + carry;
      if (rounding_offset == 0 && d > 9) {
        _digits.insert(0, 0);
        _decimal += 1;
        rounding_offset += 1;
      }
      carry = d < 10 ? 0 : 1;
      _digits[rounding_offset] = d % 10;
      rounding_offset -= 1;
    }
  }
}

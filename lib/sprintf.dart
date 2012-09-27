#library('sprintf');

RegExp specifier = const RegExp(r'%(?:(\d+)\$)?([\+\-\#0 ]*)(\d+|\*)?(?:\.(\d+|\*))?([difFeEgGxXos%])');
RegExp uppercase_rx = const RegExp(r'[A-Z]', ignoreCase: false);

class _Float {
  double _f;
  String _s;
  String _fraction;
  String _int;
  
  _Float(num arg) {
    this._f = arg as double;
    this._s = _f.toString();
    
    var parts = _s.split('.'); // TODO: can't rely on '.' being the decimal separator
    this._int = parts[0];
    this._fraction = parts[1];
  }
  
  int exponent() {
    if (_f.isNegative()) {
      var _leading_zeros_rx = new RegExp(r'^(0*)');
      var _match = _leading_zeros_rx.firstMatch(_fraction);
      
      if (_match != null) {
        return _match.group(1).length + 1;
      }
    }
    else {
      return _int.length - 1;
    }
    
    return 0;
  }
  
  String toString() => _s;
  
  String asFixed(int precision, {bool remove_trailing_zeros : true}) {
    String ret = _f.toStringAsFixed(precision);
    
    if (remove_trailing_zeros) {
      ret = ret.replaceFirst(new RegExp(r'0*$'), '').replaceFirst(new RegExp(r'\.$'), '');
    }
    
    return ret;
  }
  
  String asExponential(int precision, {bool remove_trailing_zeros : true}) {
    String ret = _f.toStringAsExponential(precision);
    
    var rx = new RegExp(r'(\d+)\.(\d+)(e|E)([-+]?)(\d+)');
    var match = rx.firstMatch(ret);
    
    if (match != null) {
      var _int_part = match.group(1);
      var _fraction_part = match.group(2);
      var _e = match.group(3);
      var _exp_sign = match.group(4);
      var _exp_str = match.group(5);
      var _exp = int.parse(_exp_str);
      
      if (remove_trailing_zeros) {
        _fraction_part = _fraction_part.replaceFirst(new RegExp(r'0*$'), '');
      }
      
      if (_exp < 10) {
        _exp_str = "0${_exp_str}";
      }
      
      if (_fraction_part.length == 0 && remove_trailing_zeros) {
        ret = "${_int_part}${_e}${_exp_sign}${_exp_str}";
      }
      else {
        ret = "${_int_part}.${_fraction_part}${_e}${_exp_sign}${_exp_str}";
      }
      
    }
    
    return ret;
  }
}

Map _parse_flags(String flags) {
  return {
    'sign' : flags.indexOf('+') > -1 ? '+' : '',
    'padding_char' : flags.indexOf('0') > -1 ? '0' : ' ',
    'add_space' : flags.indexOf(' ') > -1,
    'left_align' : flags.indexOf('-') > -1,
    'alternate_form' : flags.indexOf('#') > -1,
  };
}


String _get_int_str(int arg, Map options) {
  var ret = arg.abs().toRadixString(options['radix']);

  if (options['precision'] > -1) {
    throw new Exception('Precision not allowed in integer format specifier');
  }

  if (options['alternate_form']) {
    if (options['radix'] == 16) {
      ret = "0x${ret}";
    }
    else if (options['radix'] == 8 && arg != 0) {
      ret = "0${ret}";
    }
    if (options['sign'] == '+') {
      options['sign'] = '';
    }
  }

  // space "prefixes non-negative signed numbers with a space"
  if (options['add_space'] && arg > -1 && options['radix'] == 10) {
    //ret = " ${ret}";
  }

  var padding = '';
  var sign_length = options['sign'].length;
  if (options['width'] > -1 && (ret.length + sign_length) < options['width']) {
    if (options['padding_char'] == '0') {
      padding = _get_padding(options['width'] - ret.length - sign_length, '0');
    }
  }
  ret = "${options['sign']}${padding}${ret}";

  return ret;
}

String _get_float_str(String arg, Map options) {
  var ret = arg;
  
  // space "prefixes non-negative signed numbers with a space"
  if (options['add_space'] && options['sign'] != '-') {
    ret = " ${ret}";
  }
  
  if (options['sign'].length > 0) {
    ret = "${options['sign']}${ret}";
  }

  return ret;
}

String _get_padding(int count, String pad) {
  String padding_piece = pad;
  StringBuffer padding = new StringBuffer();

  while (count > 0) {
    if ((count & 1) == 1) { padding.add(padding_piece); }
    count >>= 1;
    padding_piece = "${padding_piece}${padding_piece}";
  }

  return padding.toString();
}

String _format_arg(String arg, Map options) {

  if (options['width'] > -1) {
    int diff = options['width'] - arg.length;
    if (diff > 0) {
      if (options['left_align']) {
        var padding = _get_padding(diff, ' ');
        arg = "${arg}${padding}";
      }
      else {
        var padding = _get_padding(diff, options['padding_char']);
        arg = "${padding}${arg}";
      }
    }
  }
  
  if (options['is_upper']) {
    arg = arg.toUpperCase();
  }

  return arg;
}

String sprintf(String fmt, var args) {
  String ret = '';

  int offset = 0;
  int arg_offset = 0;

  if (args is! List) {
    throw new IllegalArgumentException('Expecting list as second argument');
  }

  for (Match m in specifier.allMatches(fmt)) {
    String _parameter = m[1];
    String _flags = m[2];
    String _width = m[3];
    String _precision = m[4];
    String _type = m[5];

    String _arg_str = '';
    Map _options = {
      'is_upper' : false,
      'width' : -1,
      'precision' : -1,
      'length' : -1,
      'radix' : 10,
      'sign' : '',
    };

    _parse_flags(_flags).forEach((var K, var V) { _options[K] = V; });

    // The argument we want to deal with
    var _arg = _parameter == null ? null : args[int.parse(_parameter)];

    // parse width
    if (_width != null) {
      _options['width'] = (_width == '*' ? args[arg_offset++] : int.parse(_width));
    }

    // parse precision
    if (_precision != null) {
      _options['precision'] = (_precision == '*' ? args[arg_offset++] : int.parse(_precision));
    }

    // grab the argument we'll be dealing with
    if (_arg == null && _type != '%') {
      _arg = args[arg_offset++];
    }

    if (_type == 's') {
      _options['padding_char'] = ' ';
      _arg_str = _format_arg(_arg, _options); 
    }
    else if (_type == '%') {
      if (_flags.length > 0 || _width != null || _precision != null) {
        throw new Exception('"%" does not take any flags');
      }
      _arg_str = '%';
    }
    else { // else we're dealing with numbers

      var _formatter = _get_int_str;

      var _lower_type = _type.toLowerCase();

      if ('diox'.indexOf(_lower_type) > -1) {
        // int
        if ((_arg as num) < 0) {
          _options['sign'] = '-';
          _arg = -_arg;
        }
        
        _options['radix'] = _lower_type == 'x' ? 16 : (_lower_type == 'o' ? 8 : 10);
      }
      else if ('efg'.indexOf(_lower_type) > -1) {
        // float
        _formatter = _get_float_str;

        if ((_arg as num).isInfinite()) {
          if (_arg.isNegative()) {
            _options['sign'] = '-';
          }

          _arg = 'inf';
          _options['padding_char'] = ' ';
        }
        if ((_arg as num).isNaN()) {
          _arg = 'nan';
          _options['padding_char'] = ' ';
        }

        if (_options['precision'] == -1) {
          _options['precision'] = 6; // TODO: make this configurable
        }
        else if (_lower_type == 'g' && _options['precision'] == 0) {
          _options['precision'] = 1;
        }
        if (_arg is num) {
          if (_arg.isNegative()) {
            _arg = -_arg;
            _options['sign'] = '-';
          }
          
          var _f = new _Float(_arg);
          
          if (_lower_type == 'e') {
            _arg = _f.asExponential(_options['precision'], remove_trailing_zeros : false);
          }
          else if (_lower_type == 'f') {
            _arg = _f.asFixed(_options['precision'], remove_trailing_zeros : false);
          }
          else { // type == g
            var _exp = _f.exponent();
            
            if (-4 <= _exp && _exp < _options['precision']) {
              _arg = _f.asFixed(_options['precision'] - 1 - _exp);
            }
            else {
              _arg = _f.asExponential(_options['precision'] - 1);
            }
          }
          
        }

      }
      else {
        throw new IllegalArgumentException("Unknown format type ${_type}");
      }

      _options['is_upper'] = uppercase_rx.hasMatch(_type);

      _arg_str = _format_arg(_formatter(_arg, _options), _options);
    }

    // Add the pre-format string to the return
    ret = ret.concat(fmt.substring(offset, m.start()));
    offset = m.end();

    ret = ret.concat(_arg_str);
  }

  return ret.concat(fmt.substring(offset));
}
#library('sprintf');

RegExp specifier = const RegExp(@"%(?:(\d+)\$)?([\+\-\#0 ]*)(\d+|\*)?(?:\.(\d+|\*))?([difFeEgGxXos%])");

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
  }
  
  // space "prefixes non-negative signed numbers with a space"
  if (options['add_space'] && arg > -1) {
    ret = " ${ret}";
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
String _get_float_str(num arg, Map options) {
  return arg.toString();
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
    
    if (_type == 's') { _arg_str = _arg; }
    else if (_type == '%') { 
      if (_flags.length > 0) {
        throw new Exception('"%" does not take any flags');
      }
      _arg_str = '%'; 
    }
    else { // else we're dealing with numbers
      
      var _formatter = _get_int_str;
      
      if ((_arg as num) < 0) {
        _options['sign'] = '-';
      }
      
      if (['d', 'i'].indexOf(_type) > -1) {}
      else if (['f', 'F'].indexOf(_type) > -1) {
        _options['is_upper'] = _type == 'F';
        _formatter = _get_float_str;
      }
      else if (['E', 'e'].indexOf(_type) > -1) {
        _options['is_upper'] = _type == 'E';
        _formatter = _get_float_str;
      }
      else if (['G', 'g'].indexOf(_type) > -1) {
        _options['is_upper'] = _type == 'G';
        _formatter = _get_float_str;
      }
      else if (['X', 'x'].indexOf(_type) > -1) {
        _options['is_upper'] = _type == 'X';
        _options['radix'] = 16;
      }
      else if (_type == 'o') {
        _options['radix'] = 8;
      }
      else {
        throw new IllegalArgumentException(_type);
      }
      
      _arg_str = _format_arg(_formatter(_arg, _options), _options);
    }
    
    // Add the pre-format string to the return
    ret = ret.concat(fmt.substring(offset, m.start()));
    offset = m.end();
    
    ret = ret.concat(_arg_str);
  }
  
  return ret.concat(fmt.substring(offset));
}
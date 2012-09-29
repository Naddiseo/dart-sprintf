#library('int_formatter');
#import('Formatter.dart');


class IntFormatter extends Formatter {
  int _arg;
  const int MAX_INT = 9007199254740992; // javascript's max int
  
  IntFormatter(this._arg, var fmt_type, var options) : super(fmt_type, options);
  
  String toString() {
    var ret = '';
    var prefix = '';
    
    options['radix'] = fmt_type == 'x' ? 16 : (fmt_type == 'o' ? 8 : 10);
    
    if (_arg < 0) {
      _arg = _arg.abs();
      if (options['radix'] == 10) {
        options['sign'] = '-';
      }
      else {
        _arg = (MAX_INT - (_arg % MAX_INT)) & 0xffffffff;
      }
    }
    
    
    ret = _arg.toRadixString(options['radix']);

    if (options['alternate_form']) {
      if (options['radix'] == 16) {
        prefix = "0x";
      }
      else if (options['radix'] == 8 && _arg != 0) {
        prefix = "0";
      }
      if (options['sign'] == '+') {
        options['sign'] = '';
      }
    }

    // space "prefixes non-negative signed numbers with a space"
    if ((options['add_space'] && options['sign'] == '' && _arg > -1 && options['radix'] == 10)) {
      options['sign'] = ' ';
    }
    
    if (options['radix'] != 10) {
      options['sign'] = '';
    }
    
    var padding = '';
    var min_digits = options['precision'];
    var min_chars = options['width'];
    var num_length = ret.length;
    var sign_length = options['sign'].length;
    var str_len = 0;
    
    if (min_digits > num_length) {
      padding = get_padding(min_digits - num_length, '0');
      ret = "${padding}${ret}";
      num_length = ret.length;
      padding = '';
    }
    
    // current number of characters that will be printed
    str_len = num_length + sign_length + prefix.length;
    
    if (min_chars > str_len) {
      if (options['padding_char'] == '0') {
        padding = get_padding(min_chars - str_len, '0');
      }
      else {
        padding = get_padding(min_chars - str_len, ' ');
      }
    }
    
    
    if (options['left_align']) {
      ret ="${options['sign']}${prefix}${ret}${padding}";
    }
    else if (options['padding_char'] == '0') {
      ret = "${options['sign']}${prefix}${padding}${ret}";
    }
    else {
      ret = "${padding}${options['sign']}${prefix}${ret}";
    }
    
    if (options['is_upper']) {
      ret = ret.toUpperCase();
    }
    
    return ret;
  }
}

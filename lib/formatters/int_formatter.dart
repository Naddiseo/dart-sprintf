#library('int_formatter');
#import('Formatter.dart');

class IntFormatter extends Formatter {
  int _arg;
  
  IntFormatter(this._arg, var fmt_type, var options) : super(fmt_type, options);
  
  String toString() {
    var ret = '';
    if (_arg < 0) {
      options['sign'] = '-';
    }
    
    options['radix'] = fmt_type == 'x' ? 16 : (fmt_type == 'o' ? 8 : 10);
    
    ret = _arg.abs().toRadixString(options['radix']);

    if (options['precision'] > -1) {
      throw new Exception('Precision not allowed in integer format specifier');
    }

    if (options['alternate_form']) {
      if (options['radix'] == 16) {
        ret = "0x${ret}";
      }
      else if (options['radix'] == 8 && _arg != 0) {
        ret = "0${ret}";
      }
      if (options['sign'] == '+') {
        options['sign'] = '';
      }
    }

    // space "prefixes non-negative signed numbers with a space"
    if (options['add_space'] && _arg > -1 && options['radix'] == 10) {
      //ret = " ${ret}";
    }

    var padding = '';
    var sign_length = options['sign'].length;
    if (options['width'] > -1 && (ret.length + sign_length) < options['width']) {
      if (options['padding_char'] == '0') {
        padding = get_padding(options['width'] - ret.length - sign_length, '0');
      }
    }
    ret = "${options['sign']}${padding}${ret}";

    return ret;
  }
}

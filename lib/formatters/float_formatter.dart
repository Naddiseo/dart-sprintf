#library('float_formatter');
#import('dart:math');
#import('Formatter.dart');

class FloatFormatter extends Formatter {
  double _arg;
  String _int = '';
  String _fraction = '';
  
  FloatFormatter(this._arg, var fmt_type, var options) : super(fmt_type, options) {
    var parts = _arg.toString().split('.'); // TODO: can't rely on '.' being the decimal separator
    this._int = parts[0].replaceAll('-', '');
    if (parts.length > 1) {
      this._fraction = parts[1];
    }
  }
  
  String toString() {
    String ret = '';
    
    if (options['add_space'] && options['sign'] == '' && _arg >= 0) {
      options['sign'] = ' ';
    }
    
    if ((_arg as num).isInfinite()) {
      if (_arg.isNegative()) {
        options['sign'] = '-';
      }

      ret = 'inf';
      options['padding_char'] = ' ';
    }
    
    if ((_arg as num).isNaN()) {
      ret = 'nan';
      options['padding_char'] = ' ';
    }

    if (options['precision'] == -1) {
      options['precision'] = 6; // TODO: make this configurable
    }
    else if (fmt_type == 'g' && options['precision'] == 0) {
      options['precision'] = 1;
    }
    
    if (_arg is num) {
      if (_arg.isNegative()) {
        _arg = -_arg;
        options['sign'] = '-';
      }
      
      if (fmt_type == 'e') {
        ret = asExponential(options['precision'], remove_trailing_zeros : false);
      }
      else if (fmt_type == 'f') {
        ret = asFixed(options['precision'], remove_trailing_zeros : false);
      }
      else { // type == g
        var _exp = exponent();
        var sig_digs = options['precision'];
        
        if (-4 <= _exp && _exp < options['precision']) {
          sig_digs -= _int.length;
          var precision = max(options['precision'] - 1 - _exp, sig_digs);
          
          ret = asFixed(precision, remove_trailing_zeros : !options['alternate_form']);
        }
        else {
          ret = asExponential(options['precision'] - 1, remove_trailing_zeros : options['alternate_form']);
        }
      }
    }
    
    var min_chars = options['width'];
    var str_len = ret.length + options['sign'].length;
    var padding = '';
    
    if (min_chars > str_len) {
      if (options['padding_char'] == '0' && !options['left_align']) {
        padding = get_padding(min_chars - str_len, '0');
      }
      else {
        padding = get_padding(min_chars - str_len, ' ');
      }
    }
    
    if (options['left_align']) {
      ret ="${options['sign']}${ret}${padding}";
    }
    else if (options['padding_char'] == '0') {
      ret = "${options['sign']}${padding}${ret}";
    }
    else {
      ret = "${padding}${options['sign']}${ret}";
    }
    
    if (options['is_upper']) {
      ret = ret.toUpperCase();
    }
    
    return ret;
  }

  int exponent() {
    if (_arg.isNegative()) {
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
  
  String asFixed(int precision, {bool remove_trailing_zeros : true, int sig_digs : -1}) {
    String ret = _arg.toStringAsFixed(precision);
    
    if (remove_trailing_zeros && sig_digs == -1) {
      ret = ret.replaceFirst(new RegExp(r'0*$'), '').replaceFirst(new RegExp(r'\.$'), '');
    }
    
    return ret;
  }
  
  String asExponential(int precision, {bool remove_trailing_zeros : true, int sig_digs : -1}) {
    String ret = _arg.toStringAsExponential(precision);
    
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
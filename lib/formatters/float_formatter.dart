#library('float_formatter');
#import('Formatter.dart');

class FloatFormatter extends Formatter {
  double _arg;
  String _int;
  String _fraction;
  
  FloatFormatter(this._arg, var fmt_type, var options) : super(fmt_type, options) {
    var parts = _arg.toString().split('.'); // TODO: can't rely on '.' being the decimal separator
    this._int = parts[0];
    this._fraction = parts[1];
  }
  
  String toString() {
    String ret = '';
    
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
        
        if (-4 <= _exp && _exp < options['precision']) {
          ret = asFixed(options['precision'] - 1 - _exp);
        }
        else {
          ret = asExponential(options['precision'] - 1);
        }
      }
      
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
  
  String asFixed(int precision, {bool remove_trailing_zeros : true}) {
    String ret = _arg.toStringAsFixed(precision);
    
    if (remove_trailing_zeros) {
      ret = ret.replaceFirst(new RegExp(r'0*$'), '').replaceFirst(new RegExp(r'\.$'), '');
    }
    
    return ret;
  }
  
  String asExponential(int precision, {bool remove_trailing_zeros : true}) {
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
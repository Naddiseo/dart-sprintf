#library('string_formatter');
#import('Formatter.dart');

class StringFormatter extends Formatter {
  String _arg;
  

  StringFormatter(this._arg, var fmt_type, var options) : super(fmt_type, options) {
    options['padding_char'] = ' ';
  }
  
  String toString() {
    return _arg;
  }
}
part of sprintf;

abstract class Formatter {
  var fmt_type;
  var options;

  Formatter(this.fmt_type, this.options);

  static String get_padding(int count, String pad) {
    var padding_piece = pad;
    var padding = StringBuffer();

    while (count > 0) {
      if ((count & 1) == 1) {
        padding.write(padding_piece);
      }
      count >>= 1;
      padding_piece = '${padding_piece}${padding_piece}';
    }

    return padding.toString();
  }

  String asString();
}

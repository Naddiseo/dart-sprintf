library sprintf_test;

import 'package:test/test.dart';

import 'package:sprintf/sprintf.dart';

part 'testing_data.dart';

void test_testdata() {
  expectedTestData.forEach((prefix, type_map) {
    group('"%$prefix Tests, ', () {
      type_map.forEach((type, expected_array) {
        var fmt = '|%${prefix}${type}|';
        var input_array = expectedTestInputData[type]!;

        assert(input_array.length == expected_array.length);

        for (var i = 0; i < input_array.length - 1; i++) {
          var raw_input = input_array[i];
          var expected = expected_array[i];
          final input = raw_input is! List ? [raw_input] : raw_input;

          if (expected == '"throwsA"') {
            test('Expecting "${fmt}".format(${raw_input}) to throw',
                () => expect(() => sprintf(fmt, input), throwsA(anything)));
          } else {
            test('"${fmt}".format(${raw_input}) == "${expected}"',
                () => expect(sprintf(fmt, input), expected));
          }
        }
      }); // type_map
    }); // group
  }); // _expected
}

void test_bug0001() {
  test('|%x|%X| 255', () => expect(sprintf('|%x|%X|', [255, 255]), '|ff|FF|'));
}

void test_bug0006a() {
  test('|%.0f| 5.466', () => expect(sprintf('|%.0f|', [5.466]), '|5|'));
  test('|%.0g| 5.466', () => expect(sprintf('|%.0g|', [5.466]), '|5|'));
  test('|%.0e| 5.466', () => expect(sprintf('|%.0e|', [5.466]), '|5e+00|'));
}

void test_bug0006b() {
  test('|%.2f| 5.466', () => expect(sprintf('|%.2f|', [5.466]), '|5.47|'));
  test('|%.2g| 5.466', () => expect(sprintf('|%.2g|', [5.466]), '|5.5|'));
  test('|%.2e| 5.466', () => expect(sprintf('|%.2e|', [5.466]), '|5.47e+00|'));
}

void test_bug0009() {
  test('|%.2f| 2.09846', () => expect(sprintf('|%.2f|', [2.09846]), '|2.10|'));
}

void test_bug0010() {
  test('|%.1f| 5.34', () => expect(sprintf('|%.1f|', [5.34]), '|5.3|'));
  test('|%.1f| 22.51', () => expect(sprintf('|%.1f|', [22.51]), '|22.5|'));
  test('|%.0f| 22.5', () => expect(sprintf('|%.0f|', [22.5]), '|23|'));
  test('|%.0f| 22.77', () => expect(sprintf('|%.0f|', [22.77]), '|23|'));
}

void test_javascript_decimal_limit() {
  test(
      '%d 9007199254740991',
      () => expect(
          sprintf('|%d|', [9007199254740991 + 0]), '|9007199254740991|'));
  //test('%d 9007199254740992', () => expect(sprintf('|%d|', [9007199254740991+1]), '|0|'));
  //test('%d 9007199254740993', () => expect(sprintf('|%d|', [9007199254740991+2]), '|1|'));

  test(
      '%x 9007199254740991',
      () =>
          expect(sprintf('|%x|', [9007199254740991 + 0]), '|1fffffffffffff|'));
  //test('%x 9007199254740992', () => expect(sprintf('|%x|', [9007199254740991+1]), '|0|'));
  //test('%x 9007199254740993', () => expect(sprintf('|%x|', [9007199254740991+2]), '|1|'));

  test('%x -9007199254740991',
      () => expect(sprintf('|%x|', [-9007199254740991 + 0]), '|1|'));
  //test('%x -9007199254740992', () => expect(sprintf('|%x|', [-9007199254740991+1]), '|2|'));
  //test('%x -9007199254740993', () => expect(sprintf('|%x|', [-9007199254740991+2]), '|3|'));
}

void test_unsigned_neg_to_53bits() {
  test('|%x|%X| -0', () => expect(sprintf('|%x|%X|', [-0, -0]), '|0|0|'));
  test(
      '|%x|%X| -1',
      () => expect(
          sprintf('|%x|%X|', [-1, -1]), '|1fffffffffffff|1FFFFFFFFFFFFF|'));
  test(
      '|%x|%X| -2',
      () => expect(
          sprintf('|%x|%X|', [-2, -2]), '|1ffffffffffffe|1FFFFFFFFFFFFE|'));
}

void test_int_formatting() {
  test('|%+d|% d| 2', () => expect(sprintf('|%+d|% d|', [2, 2]), '|+2| 2|'));
  test('|%+d|% d| -2', () => expect(sprintf('|%+d|% d|', [-2, -2]), '|-2|-2|'));
  test(
      '|%+x|% X|%#x| -2',
      () => expect(sprintf('|%+x|% X|%#x|', [-2, -2, -2]),
          '|1ffffffffffffe|1FFFFFFFFFFFFE|0x1ffffffffffffe|'));
}

void test_large_exponents_e() {
  test('|%e| 1.79e+308',
      () => expect(sprintf('|%e|', [1.79e+308]), '|1.790000e+308|'));
  test('|%e| 1.79e-308',
      () => expect(sprintf('|%e|', [1.79e-308]), '|1.790000e-308|'));
  test('|%e| -1.79e+308',
      () => expect(sprintf('|%e|', [-1.79e+308]), '|-1.790000e+308|'));
  test('|%e| -1.79e-308',
      () => expect(sprintf('|%e|', [-1.79e-308]), '|-1.790000e-308|'));
}

void test_large_exponents_g() {
  test('|%g| 1.79e+308',
      () => expect(sprintf('|%g|', [1.79e+308]), '|1.79e+308|'));
  test('|%g| 1.79e-308',
      () => expect(sprintf('|%g|', [1.79e-308]), '|1.79e-308|'));
  test('|%g| -1.79e+308',
      () => expect(sprintf('|%g|', [-1.79e+308]), '|-1.79e+308|'));
  test('|%g| -1.79e-308',
      () => expect(sprintf('|%g|', [-1.79e-308]), '|-1.79e-308|'));
}

void test_large_exponents_f() {
  // ignore: todo
  // TODO: C's printf introduces errors after 20 decimal places
  test('|%f| 1.79e+308',
      () => expect(sprintf('|%.3f|', [1.79e+308]), '|1.79e+308|'));
  test('|%f| 1.79e-308',
      () => expect(sprintf('|%f|', [1.79e-308]), '|1.790000e-308|'));
  test('|%f| -1.79e+308',
      () => expect(sprintf('|%f|', [-1.79e+308]), '|-1.790000e+308|'));
  test('|%f| -1.79e-308',
      () => expect(sprintf('|%f|', [-1.79e-308]), '|-1.790000e-308|'));
}

void test_object_to_string() {
  var list = ['foo', 'bar'];
  test("|%s| ['foo', 'bar'].toString()",
      () => expect(sprintf('%s', [list]), '[foo, bar]'));
}

void test_round_bug0015() {
  var n = 1;
  test('|%.0f| 1', () => expect(sprintf('|%.0f|', [n]), '|1|'));
  test('|%.1f| 1', () => expect(sprintf('|%.1f|', [n]), '|1.0|'));
  test('|%.2f| 1', () => expect(sprintf('|%.2f|', [n]), '|1.00|'));

  test('|%.0f| 1.234', () => expect(sprintf('|%.0f|', [1.234]), '|1|'));
  test('|%.1f| 1.234', () => expect(sprintf('|%.1f|', [1.234]), '|1.2|'));
  test('|%.2f| 1.234', () => expect(sprintf('|%.2f|', [1.234]), '|1.23|'));

  test('|%.0f| 1.235', () => expect(sprintf('|%.0f|', [1.235]), '|1|'));
  test('|%.1f| 1.235', () => expect(sprintf('|%.1f|', [1.235]), '|1.2|'));
  test('|%.2f| 1.235', () => expect(sprintf('|%.2f|', [1.235]), '|1.24|'));
}

void test_bug0018() {
  test(
      '|%10.4f| 1.0', () => expect(sprintf('|%10.4f|', [1.0]), '|    1.0000|'));
}

void test_bug0022() {
  test('|%2\$d %2\$d %1\$d|',
      () => expect(sprintf('|%2\$d %2\$d %1\$d|', [5, 10]), '|10 10 5|'));

  // these next two are from the sprintf manual, and should print the same
  test('|%*d|', () => expect(sprintf('|%*d|', [5, 10]), '|   10|'));
  test('|%2\$*1\$d|', () => expect(sprintf('|%*d|', [5, 10]), '|   10|'));
}

void test_bug0033() {
  var inf = 1.0 / 0.0;
  var nan = 0.0 / 0.0;
  test(
      '|%g %G| Infinity',
      () => expect(sprintf('|%g %g %G %G|', [inf, -inf, inf, -inf]),
          '|inf -inf INF -INF|'));
  test(
      '|%g %G| NaN', () => expect(sprintf('|%g %G|', [nan, nan]), '|nan NAN|'));

  test(
      '|%f %F| Infinity',
      () => expect(sprintf('|%f %f %F %F|', [inf, -inf, inf, -inf]),
          '|inf -inf INF -INF|'));
  test(
      '|%f %F| NaN', () => expect(sprintf('|%f %F|', [nan, nan]), '|nan NAN|'));
}

void main() {
  test_bug0022();

  test('|%6.6g -1.79e+20',
      () => expect(sprintf('|%6.6g|', [-1.79E+20]), '|-1.79e+20|'));
  test('|%6.6G -1.79e+20',
      () => expect(sprintf('|%6.6G|', [-1.79E+20]), '|-1.79E+20|'));
  test_bug0018();

  //test_bug0009();
  //test_bug0010();
  //test('|%f| 1.79E+308', () => expect(sprintf('|%f|', [1.79e+308]), '|1.79e+308|'));
  test_unsigned_neg_to_53bits();
  test_int_formatting();

  test_javascript_decimal_limit();
  if (true) {
    test_testdata();
    test_large_exponents_e();
    test_large_exponents_g();
    //test_large_exponents_f();

    test_bug0001();
    test_bug0006a();
    test_bug0006b();

    test_bug0009();
    test_bug0010();

    test_object_to_string();
  }
  test_bug0033();
}

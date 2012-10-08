import 'dart:math';

import 'package:unittest/unittest.dart';

import 'package:sprintf/sprintf.dart';

part 'test_data.dart';

var _test_suite_input = {
  '%': [1, -1, 'a', 'asdf', 123],
  'E': [123.0, -123.0, 0, 1.79E+20, -1.79E+20, 1.79E-20, -1.79E-20],
  'F': [123.0, -123.0, 0, 1.79E+20, -1.79E+20, 1.79E-20, -1.79E-20],
  'G': [123.0, -123.0, 0, 1.79E+20, -1.79E+20, 1.79E-20, -1.79E-20],
  'X': [123, -123, 0, 9007199254740991],
  'd': [123, -123, 0, 9007199254740991],
  'e': [123.0, -123.0, 0, 1.79E+20, -1.79E+20, 1.79E-20, -1.79E-20],
  'f': [123.0, -123.0, 0, 1.79E+20, -1.79E+20, 1.79E-20, -1.79E-20],
  'g': [123.0, -123.0, 0, 1.79E+20, -1.79E+20, 1.79E-20, -1.79E-20],
  'o': [123, -123, 0, 9007199254740991],
  's': ['', 'Hello World'],
  'x': [123, -123, 0, 9007199254740991]
};

main() {
  if (true) {
  expectedTestData.forEach((prefix, type_map) {
    group('"%${prefix}" Tests, ',
        () {
          type_map.forEach((type, expected_array) {
            var fmt = "|%${prefix}${type}|";
            var input_array = _test_suite_input[type];

            assert(input_array.length == expected_array.length);

            for (var i = 0; i < input_array.length - 1; i++) {
              var raw_input = input_array[i];
              var expected = expected_array[i];
              var input = raw_input is! List ? [raw_input] : raw_input;

              if (expected == throws) {
                test("Expecting \"${fmt}\".format(${raw_input}) to throw",
                    () => expect(() => sprintf(fmt, input), expected)
                );
              }
              else {
                test("\"${fmt}\".format(${raw_input}) == \"${expected}\"",
                    () => expect(sprintf(fmt, input), expected)
                );
              }

            }

          }); // type_map
        }
    );// group
  }); // _expected
  }
  // 123.0, -123.0, "%6.6g"(1.79e-20)
  test("", () => expect(sprintf("|%e|", [123.0]), '|1.230000e+02|'));
  test("", () => expect(sprintf("|%e|", [-123.0]), '|-1.230000e+02|'));
  test("", () => expect(sprintf("|%6.6g|", [1.79e-20]), '|1.79e-20|'));
  //test("", () => expect(sprintf("|%g|", [123456.0]), '|1.79E-20|'));
  /*test("|%x|%X| 255", () => expect(sprintf("|%x|%X|", [255, 255]), '|ff|FF|'));

  test("%d 9007199254740991", () => expect(sprintf("|%d|", [9007199254740991]), '|9007199254740991|'));
  test("%d 9007199254740992", () => expect(sprintf("|%d|", [9007199254740992]), '|9007199254740992|'));
  test("%d 9007199254740993", () => expect(sprintf("|%d|", [9007199254740993]), '|9007199254740993|'));

  test("%x 9007199254740991", () => expect(sprintf("|%x|", [9007199254740991]), '|1fffffffffffff|'));
  test("%x 9007199254740992", () => expect(sprintf("|%x|", [9007199254740992]), '|20000000000000|'));
  test("%x 9007199254740993", () => expect(sprintf("|%x|", [9007199254740993]), '|20000000000001|'));
*/
 /* 
  test("%x 9007199254740991", () => expect(sprintf("|%x|", [9007199254740991]), '|-1fffffffffffff|'));
  test("%x 9007199254740992", () => expect(sprintf("|%x|", [9007199254740992]), '|-20000000000000|'));
  test("%x 9007199254740993", () => expect(sprintf("|%x|", [9007199254740993]), '|-20000000000001|'));
  */

}
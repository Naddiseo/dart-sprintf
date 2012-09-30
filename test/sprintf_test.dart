#import('../../../dart/dart-sdk/pkg/unittest/unittest.dart');
#import('../lib/sprintf.dart');
#import('dart:math');
#import('test_data.dart');

var _test_suite_input = {
  '%': [1, -1, 'a', 'asdf', 123],
  'E': [123.0, -123.0, 0, 1.79E+308],
  'F': [123.0, -123.0, 0, 1.79E+308],
  'G': [123.0, -123.0, 0, 1.79E+308],
  'X': [123, -123, 0, 9007199254740991],
  'd': [123, -123, 0, 9007199254740991],
  'e': [123.0, -123.0, 0, 1.79E+308],
  'f': [123.0, -123.0, 0, 1.79E+308],
  'g': [123.0, -123.0, 0, 1.79E+308],
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
  //test("", () => expect(sprintf("|%6.6s|", ['']), '|      |'));;
    
}
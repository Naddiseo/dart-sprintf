#import('../../../dart/dart-sdk/pkg/unittest/unittest.dart');
#import('../lib/sprintf.dart');
#import('test_data.dart');

var _test_suite_input = {
  '%': [1,-1,'a','asdf', 123],
  'E': [123.0, -123.0, 0],
  'F': [123.0, -123.0, 0],
  'G': [123.0, -123.0, 0],
  'X': [123,-123, 0],
  'd': [123, -123, 0],
  'e': [123.0, -123.0, 0],
  'f': [123.0, -123.0, 0],
  'g': [123.0, -123.0, 0],
  'o': [123, -123, 0],
  's': ['', 'Hello World'],
  'x': [123, -123, 0]
};

main() {
  expectedTestData.forEach((prefix, type_map) {
    group('"%${prefix}" Tests, ',
        () {
          type_map.forEach((type, expected_array) {
            var fmt = "|%${prefix}${type}|";
            var input_array = _test_suite_input[type];

            assert(input_array.length == expected_array.length);

            for (var i = 0; i < input_array.length - 1; i++) {
              var input = input_array[i];
              var expected = expected_array[i];

              if (expected == throws) {
                test("Expecting \"${fmt}\".format(${input}) to throw",
                    () => expect(() => sprintf(fmt, [input]), expected)
                );
              }
              else {
                test("\"${fmt}\".format(${input}) == \"${expected}\"",
                    () => expect(sprintf(fmt, [input]), expected)
                );
              }

            }

          }); // type_map
        }
    );// group
  }); // _expected

}
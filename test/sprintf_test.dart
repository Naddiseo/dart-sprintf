library sprintf_test;

import 'package:test/test.dart';

import 'package:sprintf/sprintf.dart';

part 'testing_data.dart';

test_testdata() {
  expectedTestData.forEach((prefix, type_map) {
    group('"%${prefix}" Tests, ',
        () {
      type_map.forEach((type, expected_array) {
        String fmt = "|%${prefix}${type}|";
        var input_array = expectedTestInputData[type];

        assert(input_array.length == expected_array.length);

        for (int i = 0; i < input_array.length - 1; i++) {
          var raw_input = input_array[i];
          var expected = expected_array[i];
          List input = raw_input is! List ? [raw_input] : raw_input;

          if (expected == '"throwsA"') {
            test("Expecting \"${fmt}\".format(${raw_input}) to throw",
                () => expect(() => sprintf(fmt, input), throwsA(anything))
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

test_bug0001() {
  test("|%x|%X| 255", () => expect(sprintf("|%x|%X|", [255, 255]), '|ff|FF|'));
}

test_bug0006a() {
  test("|%.0f| 5.466", () => expect(sprintf("|%.0f|", [5.466]), '|5|'));
  test("|%.0g| 5.466", () => expect(sprintf("|%.0g|", [5.466]), '|5|'));
  test("|%.0e| 5.466", () => expect(sprintf("|%.0e|", [5.466]), '|5e+00|'));
}

test_bug0006b() {
  test("|%.2f| 5.466", () => expect(sprintf("|%.2f|", [5.466]), '|5.47|'));
  test("|%.2g| 5.466", () => expect(sprintf("|%.2g|", [5.466]), '|5.5|'));
  test("|%.2e| 5.466", () => expect(sprintf("|%.2e|", [5.466]), '|5.47e+00|'));
}

test_bug0009() {
	test("|%.2f| 2.09846", () => expect(sprintf("|%.2f|", [2.09846]), '|2.10|'));
}

test_javascript_decimal_limit() {
  test("%d 9007199254740991", () => expect(sprintf("|%d|", [9007199254740991]), '|9007199254740991|'));
  test("%d 9007199254740992", () => expect(sprintf("|%d|", [9007199254740992]), '|9007199254740992|'));
  test("%d 9007199254740993", () => expect(sprintf("|%d|", [9007199254740993]), '|9007199254740993|'));

  test("%x 9007199254740991", () => expect(sprintf("|%x|", [9007199254740991]), '|1fffffffffffff|'));
  test("%x 9007199254740992", () => expect(sprintf("|%x|", [9007199254740992]), '|20000000000000|'));
  test("%x 9007199254740993", () => expect(sprintf("|%x|", [9007199254740993]), '|20000000000001|'));

  test("%x 9007199254740991", () => expect(sprintf("|%x|", [-9007199254740991]), '|ffe0000000000001|'));
  test("%x 9007199254740992", () => expect(sprintf("|%x|", [-9007199254740992]), '|ffe0000000000000|'));
  test("%x 9007199254740993", () => expect(sprintf("|%x|", [-9007199254740993]), '|ffdfffffffffffff|'));
}

test_large_exponents_e() {
  test("|%e| 1.79e+308", () => expect(sprintf("|%e|", [1.79e+308]), '|1.790000e+308|'));
  test("|%e| 1.79e-308", () => expect(sprintf("|%e|", [1.79e-308]), '|1.790000e-308|'));
  test("|%e| -1.79e+308", () => expect(sprintf("|%e|", [-1.79e+308]), '|-1.790000e+308|'));
  test("|%e| -1.79e-308", () => expect(sprintf("|%e|", [-1.79e-308]), '|-1.790000e-308|'));
}

test_large_exponents_g() {
  test("|%g| 1.79e+308", () => expect(sprintf("|%g|", [1.79e+308]), '|1.79e+308|'));
  test("|%g| 1.79e-308", () => expect(sprintf("|%g|", [1.79e-308]), '|1.79e-308|'));
  test("|%g| -1.79e+308", () => expect(sprintf("|%g|", [-1.79e+308]), '|-1.79e+308|'));
  test("|%g| -1.79e-308", () => expect(sprintf("|%g|", [-1.79e-308]), '|-1.79e-308|'));
}

test_large_exponents_f() {
  // TODO: C's printf introduces errors after 20 decimal places
  test("|%f| 1.79e+308", () => expect(sprintf("|%.3f|", [1.79e+308]), '|1.79e+308|'));
  test("|%f| 1.79e-308", () => expect(sprintf("|%f|", [1.79e-308]), '|1.790000e-308|'));
  test("|%f| -1.79e+308", () => expect(sprintf("|%f|", [-1.79e+308]), '|-1.790000e+308|'));
  test("|%f| -1.79e-308", () => expect(sprintf("|%f|", [-1.79e-308]), '|-1.790000e-308|'));
}

test_object_to_string() {
  List<String> list = ["foo", "bar"];
  int i= 1;
  test("|%s| ['foo', 'bar'].toString()", () => expect(sprintf("%s", [list]), "[foo, bar]"));
}

main() {
  if (true) {
    test_testdata();
    test_javascript_decimal_limit();
    test_large_exponents_e();
    test_large_exponents_g();
   // test_large_exponents_f();

    test_bug0001();
    test_bug0006a();
    test_bug0006b();

    test_bug0009();

    //test_object_to_string();
  }
}

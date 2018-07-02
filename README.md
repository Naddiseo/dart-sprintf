dart-sprintf
============

Dart implementation of sprintf.

[![Build Status](https://travis-ci.org/Naddiseo/dart-sprintf.svg?branch=master)](https://travis-ci.org/Naddiseo/dart-sprintf/)


ChangeLog
---------
v3.0.2 (2017-08-17)

	* Fixed bad publish

v3.0.1 (2017-08-17)

    * Fixed weak typing which stopped dartdevc from working (#11 thanks @bergwerf)

v3.0.0 (2017-04-20)

    * Fixed rounding of floats, again. Bumping major version because it's different from previous behaviour

v2.0.0 (2017-03-23)

    * Fixed rounding of floats. Bumping major version, because previous behaviour was to always round down.

v1.1.1 (2016-11-16)

	* Updated to use `test` library since `unittest` has been deprecated. 

v1.1.0 (2014-08-21)

	* **API change**: Any object with a valid `toString` method can be formatted with `'%s'` (#7)

v1.0.9 (2013-12-15)

	* Round numbers when they're truncated. (#6)

v1.0.8 (2013-10-08)

	* Remove trailing decimal point if there are no following digits (#6)

v1.0.7 (2013-05-07)

	* Update for new dart version

v1.0.6 (2013-04-16)

	* Update for new dart version

v1.0.5 (2013-03-25)

	* Fixed dependencies example in README (#5)

v1.0.4 (2013-03-21)

	* Update for new dart version
	
	* Update for new pubspec format

v1.0.3 (2013-02-12)

	* Update for dart M2

v1.0.2 (2013-01-21)

	* Pubspec and whitespace fixes

v1.0.1 (2012-11-12)

	* Update for new dart version

v1.0.0 (2012-10-08)

	First release with semver

Getting Started
---------------

Add the following to your **pubspec.yaml**:

```
dependencies:
  sprintf: "^3.0.0"
```

then run **pub install**.

Next, import dart-sprintf:

```
import 'package:sprintf/sprintf.dart';
```

### Example
```
import 'package:sprintf/sprintf.dart';

void main() {
	print(sprintf("%04i", [-42]));
	print(sprintf("%s %s", ["Hello", "World"]));
	print(sprintf("%#04x", [10]));
}
```

```
-042
Hello World
0x0a
```

Limitations
-----------

* Negative numbers are wrapped as 64bit ints when formatted as hex or octal.

Differences to C's printf

* When using fixed point printing of numbers with large exponents, C introduces errors after 20 decimal places. Dart-printf will just print 0s.

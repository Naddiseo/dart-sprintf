v7.0.0 (2022-09-30)

    * properly format Infinity and NaN for %f and %G  (#33)
    
v6.0.2 (2022-08-10)

    * pub policy compliance

v6.0.1 (2022-02-24)

    * Upgrade analyze package to dart:lint
    * code formatting
    
v6.0.0 (2021-03-04)

    * Promote null-safety to stable

v6.0.0-nullsafety (2020-12-10)

    * Add null-safety support

v5.0.0 (2020-09-25)

    * Fix #22: position arguments didn't work. Major version bump because it's
      a different API. The following now works:
      ```
      sprintf('|%2\$d %2\$d %1\$d|', [5, 10]); // '|10 10 5|'
      ```


v4.1.0 (2020-07-26)

    * Used dart padentic to fix up some code
    * changed SDK requirements to be >=2, <3

v4.0.3 (2020-07-26)

    * Fixed formatting of "1.0" (#18); it was being truncated to "1" and then
      failing the regex.

v4.0.2 (2019-02-19)

    * Fixed v4.0.1
    * Fixed rounding bug if 0 or 1 digits of rounding are requested (#15)

v4.0.1 (2019-02-19)

    * **BROKEN** Fixed rounding bug if 0 or 1 digits of rounding are requested (#15)

v4.0.0 (2018-07-02)

    * **Breaking change** (#13)
      As of dart 2, int types are going to be fixed width, and the width depends on
      implementation (dart2js vs dartvm). Dart started warning about constants that
      are greater than the max int of javascript. To fix that, this patch will limit
      int (when formatted as hex or octal) to the max limit of javascript (2**53 - 1).
      Any int outside of the +-(2**53 -1) range is not guaranteed to format correctly!

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

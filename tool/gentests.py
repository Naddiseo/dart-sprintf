from itertools import combinations, permutations
from pprint import pformat
from ctypes import *
import os

sprintf = CDLL('libc.so.6').sprintf

float_tests = [123.0, -123.0, 0.0, 1.79E+20, -1.79E+20, 1.79E-20, -1.79E-20, 5.4444466]
int_tests = [123, -123, 0, 9007199254740991]

_test_suite_input = {
  '%': [1, -1, 'a', 'asdf', 123],
  'E': float_tests,
  'F': float_tests,
  'G': float_tests,
  'X': int_tests,
  'd': int_tests,
  'e': float_tests,
  'f': float_tests,
  'g': float_tests,
  'o': int_tests,
  's': ['', 'Hello World'],
  'x': int_tests
};

val = {
    'd' : '',
    'f' : '',
    'F' : '',
    'e' : '',
    'E' : '',
    'g' : '',
    'G' : '',
    'x' : '',
    'X' : '',
    'o' : '',
    's' : '',
    '%' : '',
  }

def get_prefix():
  for i in xrange(0, 6):
    for l in combinations([' ', '-', '+', '#', '0', '6', '.6'], r = i):
      yield ''.join(l)

expected = {k : val.copy() for k in get_prefix()}

new_expected = {}

for prefix, type_map in expected.items():
	new_expected[prefix] = {}
	for fmt_type, expected in type_map.items():
	
		new_expected[prefix][fmt_type] = []
		
		pyfmt = "|{{:{}{}}}|".format(prefix.replace('-', '<'), fmt_type)
		cfmt = "|%{}{}|".format(prefix, fmt_type)
		input_array = _test_suite_input[fmt_type];
		
		if fmt_type in 'doxX':
			cfmt = cfmt.replace('d', 'lld').replace('o', 'llo').replace('x', 'llx').replace('X', 'llX')
		
		for input_data in input_array:
			ret = create_string_buffer(1024)
			try:
				if fmt_type == '%':
					if len(prefix) > 0:
						new_expected[prefix][fmt_type].append('throws')
						print cfmt, 'throws'
						continue
					else:
						sprintf(ret, cfmt, input_data)
						print cfmt, ret.value
						new_expected[prefix][fmt_type].append(ret.value)
				
				elif fmt_type in 'doxX':
											
					sprintf(ret, cfmt, c_int64(input_data))
					print cfmt, ret.value
					new_expected[prefix][fmt_type].append(ret.value)
					
					#if 'x' in fmt_type and input_data == -123:
					#	print "OUTPUT: {} {}".format(cfmt, ret.value)
				
				elif fmt_type in 'efgEFG':
					sprintf(ret, cfmt, c_double(input_data))
					print cfmt, ret.value
					new_expected[prefix][fmt_type].append(ret.value)
				
				else:
					ret = create_string_buffer(1024)
					sprintf(ret, cfmt, input_data)
					print cfmt, ret.value
					new_expected[prefix][fmt_type].append(ret.value)
			except ValueError:
				raise

this_dir = os.path.dirname(os.path.abspath(__file__))
test_data_path = os.path.abspath(os.path.join(this_dir, '..', 'test', 'testing_data.dart'))

def prettify(expr):
	formatted_data = pformat(expr)
	
	formatted_data = formatted_data.replace(']}', ']\n  }')
	formatted_data = formatted_data.replace(": {'%':", ": {\n    '%':")
	formatted_data = formatted_data.replace('}}', '}\n}')
	formatted_data = formatted_data.replace("{'': {", "{\n  '': {")
	formatted_data = formatted_data.replace("'throws'", "throws")
	
	return formatted_data

with open(test_data_path, 'w') as fp:
	
	fp.write('part of sprintf_test;\n')
	fp.write('var expectedTestData = ')
	fp.write(prettify(new_expected))
	fp.write(';\n')
	
	fp.write('var expectedTestInputData = ')
	fp.write(prettify(_test_suite_input))
	fp.write(';\n')

			

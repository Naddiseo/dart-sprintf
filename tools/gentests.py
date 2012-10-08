from itertools import combinations, permutations
from pprint import pformat
from ctypes import *
import os

sprintf = CDLL('libc.so.6').sprintf

_test_suite_input = {
  '%': [1, -1, 'a', 'asdf', 123],
  'E': [123.0, -123.0, 0.0, 1.79E+20, -1.79E+20, 1.79E-20, -1.79E-20],
  'F': [123.0, -123.0, 0.0, 1.79E+20, -1.79E+20, 1.79E-20, -1.79E-20],
  'G': [123.0, -123.0, 0.0, 1.79E+20, -1.79E+20, 1.79E-20, -1.79E-20],
  'X': [123, -123, 0, 9007199254740991],
  'd': [123, -123, 0, 9007199254740991],
  'e': [123.0, -123.0, 0.0, 1.79E+20, -1.79E+20, 1.79E-20, -1.79E-20],
  'f': [123.0, -123.0, 0.0, 1.79E+20, -1.79E+20, 1.79E-20, -1.79E-20],
  'g': [123.0, -123.0, 0.0, 1.79E+20, -1.79E+20, 1.79E-20, -1.79E-20],
  'o': [123, -123, 0, 9007199254740991],
  's': ['', 'Hello World'],
  'x': [123, -123, 0, 9007199254740991]
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
test_data_path = os.path.abspath(os.path.join(this_dir, '..', 'test', 'test_data.dart'))

with open(test_data_path, 'w') as fp:
	formatted_data = pformat(new_expected)
	
	formatted_data = formatted_data.replace(']}', ']\n  }')
	formatted_data = formatted_data.replace(": {'%':", ": {\n    '%':")
	formatted_data = formatted_data.replace('}}', '}\n}')
	formatted_data = formatted_data.replace("{'': {", "{\n  '': {")
	formatted_data = formatted_data.replace("'throws'", "throws")
	
	fp.write('var expectedTestData = ')
	fp.write(formatted_data)
	fp.write(';\n')


			

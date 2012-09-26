from itertools import combinations, permutations
from pprint import pformat
from ctypes import *

sprintf = CDLL('libc.so.6').sprintf

_test_suite_input = {
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

val={
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
    for l in combinations([' ', '-','+','#','0','6', '.6'], r=i):
      yield ''.join(l)

expected = {k : val.copy() for k in get_prefix()}

new_expected = {}

for prefix, type_map in expected.items():
	new_expected[prefix] = {}
	for fmt_type, expected in type_map.items():
	
		new_expected[prefix][fmt_type] = []
		
		fmt = "|{{:{}{}}}|".format(prefix, fmt_type)
		cfmt = "|%{}{}|".format(prefix,fmt_type)
		input_array = _test_suite_input[fmt_type];
		
		for input_data in input_array:
			try:
				if fmt_type == '%':
					new_expected[prefix][fmt_type].append('throws')
					print fmt, 'throws'
					continue
				else:
					print fmt, fmt.replace('-', '<').format(input_data)
					new_expected[prefix][fmt_type].append(fmt.replace('-', '<').format(input_data))
			except ValueError:
				ret = create_string_buffer(255)
				
				try:
					if isinstance(input_data, float):
						sprintf(ret, cfmt, c_double(input_data))
					print cfmt, ret.value
					new_expected[prefix][fmt_type].append(ret.value)
				except ArgumentError:
					print "sprintf error {} {!r}".format(cfmt, input_data)

with open('test_data.dart', 'w') as fp:
	formatted_data = pformat(new_expected)
	
	formatted_data = formatted_data.replace(']}', ']\n  }')
	formatted_data = formatted_data.replace(": {'%':", ": {\n    '%':")
	formatted_data = formatted_data.replace('}}', '}\n}')
	formatted_data = formatted_data.replace("{'': {","{\n  '': {")
	formatted_data = formatted_data.replace("'throws'", "throws")
	
	fp.write('var _expected = ')
	fp.write(formatted_data)
	fp.write(';\n')


			

module rsv

import encoding.utf8

const eov = u8(0xFF)
const eor = u8(0xFD)
const null = u8(0xFE)

fn val2bytes(val ?string) ![]u8 {
	return if str := val {
		if utf8.validate_str(str) {
			str.bytes()
		} else {
			error('Invalid UTF8 string ${str}')
		}
	} else {
		[null]
	}
}

pub fn encode(rows [][]?string) ![]u8 {
	mut res := []u8{}
	for row in rows {
		for val in row {
			res << val2bytes(val)!
			res << eov
		}
		res << eor
	}
	return res
}

fn bytes2val(bytes []u8, i int, j int) ?string {
	return if j == i {
		''
	} else if bytes[i] == null {
		none
	} else {
		bytes[i..j].bytestr()
	}
}

// unvalidated decode
pub fn decode(bytes []u8) [][]?string {
	mut res := [][]?string{}
	mut row := []?string{}
	mut i := 0

	for j := 0; j < bytes.len; j++ {
		if bytes[j] == eov {
			val := bytes2val(bytes, i, j)
			row << val
			i = j + 1
		}

		if bytes[i] == eor {
			res << row
			row = []?string{}
			j = 1
			i += 1
		}
	}

	return res
}

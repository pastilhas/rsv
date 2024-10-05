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

// unvalidated decode
pub fn decode(bytes []u8) [][]?string {
	mut table := [][]?string{}
	mut row := []?string{}
	mut start := 0

	for i := 0; i < bytes.len; i++ {
		if bytes[i] == eov {
			if i == start {
				row << ''
			} else if bytes[start] == null {
				row << none
			} else {
				row << bytes[start..i].bytestr()
			}

			start = i + 1
			continue
		}

		if bytes[i] == eor {
			table << row
			row = []?string{}
			start += 1
		}
	}

	return table
}

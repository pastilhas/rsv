module rsv

const eov_flag = 0xFF
const null_flag = 0xFE
const eor_flag = 0xFD
const empty_val = ''
const null_val = none

// unvalidated encode
pub fn encode(table [][]?string) []u8 {
	mut bytes := []u8{}

	for row in table {
		for val in row {
			if str := val {
				bytes << str.bytes()
			} else {
				bytes << null_flag
			}

			bytes << eov_flag
		}

		bytes << eor_flag
	}

	return bytes
}

// unvalidated decode
pub fn decode(bytes []u8) [][]?string {
	mut table := [][]?string{}
	mut row := []?string{}
	mut start := 0

	for i := 0; i < bytes.len; i++ {
		if bytes[i] == eov_flag {
			if i == start {
				row << empty_val
			} else if bytes[start] == null_flag {
				row << null_val
			} else {
				row << bytes[start..i].bytestr()
			}

			start = i + 1
			continue
		}

		if bytes[i] == eor_flag {
			table << row
			row = []?string{}
			start += 1
		}
	}

	return table
}

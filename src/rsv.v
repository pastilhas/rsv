module rsv

const (
	eov_flag  = 0xFF
	null_flag = 0xFE
	eor_flag  = 0xFD
	empty_val = ''
	null_val  = none
)

// unvalidated encode
pub fn encode(table [][]?string) []u8 {
	mut bytes := []u8{}

	for row in table {
		for val in row {
			if str := val {
				bytes << str.bytes()
			} else {
				bytes << rsv.null_flag
			}

			bytes << rsv.eov_flag
		}

		bytes << rsv.eor_flag
	}

	return bytes
}

// unvalidated decode
pub fn decode(bytes []u8) [][]?string {
	mut table := [][]?string{}
	mut row := []?string{}
	mut start := 0

	for i := 0; i < bytes.len; i++ {
		if bytes[i] == rsv.eov_flag {
			if i == start {
				row << rsv.empty_val
			} else if bytes[start] == rsv.null_flag {
				row << rsv.null_val
			} else {
				row << bytes[start..i].bytestr()
			}

			start = i + 1
			continue
		}

		if bytes[i] == rsv.eor_flag {
			table << row
			row = []?string{}
			start += 1
		}
	}

	return table
}

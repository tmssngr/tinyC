#include "io.h"
#include "random.h"

#ifdef Z8
const WIDTH = 38
const COMPACT = true
#else
const WIDTH = 40
const COMPACT = false
#endif

const HEIGHT = 20;
const BOMB_RATIO = 90;
const BOMB_COUNT = HEIGHT * WIDTH * BOMB_RATIO / 1000;
const REVEAL_STACK_CAPACITY = 16;
const REVEAL_STACK_OVERFLOW = 0xFF;

const maskBomb = 0x80;
const maskFlag = 0x40;
const maskOpen = 0x20;
const maskCount = 0x0F;

u8 field[WIDTH * HEIGHT];
u8 revealStackRows[REVEAL_STACK_CAPACITY];
u8 revealStackColumns[REVEAL_STACK_CAPACITY];
i16 revealStackIndices[REVEAL_STACK_CAPACITY];
i16* revealStackIndexTop;
u8 revealStackSize;

i16 rowColumnToCell(u8 row, u8 column) {
	i16 r = row as i16
	i16 c = column as i16
	return r * WIDTH + c;
}

i16 columnToX(u8 column) {
	i16 c = column as i16
	if COMPACT {
		return c
	}

	return (c + 1) * 2
}

void printCellAt(u8 row, u8 column) {
	u8 cell = field[rowColumnToCell(row, column)]
	printCellAt(cell, row, column)
}

void printCellAt(u8 cell, u8 row, u8 column) {
	i16 x = columnToX(column)
	setCursor(row as i16, x)
	printCell(cell, row, column)
}

void printCell(u8 cell, u8 row, u8 column) {
	u8 chr = '.';
	if (cell & maskOpen) != 0 {
		if (cell & maskBomb) != 0 {
			chr = '*';
		}
		else {
			i16 index = rowColumnToCell(row, column)
			u8 count = field[index] & maskCount
			if (count > 0) {
				chr = '0' + count;
			}
			else {
				chr = ' ';
			}
		}
	}
	else if (cell & maskFlag) != 0 {
		chr = '#';
	}
	printChar(chr);
}

#ifdef Z8
void initializeScreen() {
	printChar(0x0C)
	printField()
}
#else
void initializeScreen() {
	printField()
}
#endif

void printField() {
	setCursor(0i16, 0i16);
	for (u8 row = 0; row < HEIGHT; row += 1) {
		setCursor(row as i16, 0)
		if !COMPACT {
			printChar('|')
		}
		for (u8 column = 0; column < WIDTH; column += 1) {
			if !COMPACT {
				printChar(' ')
			}
			u8 cell = field[rowColumnToCell(row, column)]
			printCell(cell, row, column);
		}
		if !COMPACT {
			printString(" |");
		}
	}
}

void showCursor(u8 row, u8 column, bool show) {
	if COMPACT {
		if show {
			i16 x = columnToX(column)
			setCursor(row as i16, x)
		}
		return
	}

	i16 x = columnToX(column)
	setCursor(row as i16, x - 1)
	u8 chr = ' '
	if show {
		chr = '['
	}
	printChar(chr)

	setCursor(row as i16, x + 1)
	if show {
		chr = ']'
	}
	printChar(chr)
}

void printSpaces(i16 i) {
	for (; i > 0; i -= 1) {
		printChar('0');
	}
}

u8 getDigitCount(i16 value) {
	u8 count = 0;
	if (value < 0) {
		count = 1;
		value = -value;
	}

	while (true) {
		count += 1;
		value /= 10;
		if (value == 0) {
			break;
		}
	}

	return count;
}

i16 getHiddenCount() {
	i16 count = 0;
	for (u8 r = 0; r < HEIGHT; r += 1) {
		for (u8 c = 0; c < WIDTH; c += 1) {
			u8 cell = field[rowColumnToCell(r, c)]
			if ((cell & (maskFlag | maskOpen)) == 0) {
				count = count + 1;
			}
		}
	}
	return count;
}

bool printLeft() {
	i16 count = getHiddenCount();

	i16 leftDigits = getDigitCount(count) as i16
	i16 bombDigits = getDigitCount(BOMB_COUNT) as i16
	setCursor(HEIGHT, 6);
	printSpaces(bombDigits - leftDigits);
	printUint(count);
	return count == 0;
}

i16 abs(i16 a) {
	if (a < 0) {
		return -a;
	}
	return a;
}

void clearField() {
	i16 index = 0
	for (i16 i = WIDTH as i16 * HEIGHT as i16; i > 0; i -= 1, index += 1) {
		field[index] = 0
	}
}

i16 initField(u8 curr_r, u8 curr_c) {
	i16 r = curr_r as i16
	i16 c = curr_c as i16
	i16 bombCount = 0;
	for (i16 bombs = BOMB_COUNT; bombs > 0; bombs -= 1) {
		i16 row = random16() % HEIGHT;
		i16 column = random16() % WIDTH;
		if (abs(row    - r) > 1 ||
		    abs(column - c) > 1) {
			if setBomb(row as u8, column as u8) {
				bombCount += 1
			}
		}
	}
	return bombCount;
}

bool setBomb(u8 row, u8 column) {
	i16 index = rowColumnToCell(row, column)
	if field[index] == maskBomb {
		return false
	}
	field[index] = maskBomb

	u8 rowFrom = row
	if rowFrom > 0 {
		rowFrom -= 1
		index -= WIDTH
	}
	u8 rowTo = row + 1
	if rowTo >= HEIGHT {
		rowTo -= 1
	}

	u8 colFrom = column
	if colFrom > 0 {
		colFrom -= 1
		index -= 1
	}
	u8 colTo = column + 1
	if colTo >= WIDTH {
		colTo -= 1
	}

	u8 count = 0;
	for (u8 r = rowFrom; r <= rowTo; r += 1) {
		for (u8 c = colFrom; c <= colTo; c += 1, index += 1) {
			if r == row && c == column {
				continue
			}

			u8 cell = field[index]
			if (cell & maskBomb) == 0 {
				u8 count = cell & maskCount
				count = count + 1;
				field[index] = count
			}
		}
		index = index - colTo as i16 + colFrom as i16 + WIDTH - 1
	}
	return true
}

void maybeRevealAround(u8 row, u8 column) {
	printCellAt(row, column)
	i16 index = rowColumnToCell(row, column)
	if (field[index] & maskCount) != 0 {
		return
	}

	revealStackRows[0] = row
	revealStackColumns[0] = column
	*revealStackIndices = index
	revealStackIndexTop = revealStackIndices + 1
	revealStackSize = 1
	while (revealStackSize > 0) {
		u8 stackSize = revealStackSize - 1
		revealStackSize = stackSize
		row = revealStackRows[stackSize]
		column = revealStackColumns[stackSize]
		i16* stackIndex = revealStackIndexTop + -1
		revealStackIndexTop = stackIndex
		index = *stackIndex
		revealNeighbors(row, column, index)
		if (revealStackSize == REVEAL_STACK_OVERFLOW) {
			break
		}
	}
	if (revealStackSize != REVEAL_STACK_OVERFLOW) {
		return
	}

	bool changed = true
	while (changed) {
		changed = false

		index = 0
		for (u8 r = 0; r < HEIGHT; r += 1) {
			for (u8 c = 0; c < WIDTH; c += 1, index += 1) {
				u8 cell = field[index]
				if (cell & maskOpen) == 0 || (cell & maskBomb) != 0 {
					continue;
				}
				if (field[index] & maskCount) != 0 {
					continue
				}

				if revealNeighbors(r, c, index) {
					changed = true
				}
			}
		}

		if !changed {
			break
		}

		u8 r = HEIGHT
		while true {
			if r == 0 {
				break
			}
			r -= 1

			u8 c = WIDTH
			while true {
				if c == 0 {
					break
				}
				c -= 1
				index -= 1
				u8 cell = field[index]
				if (cell & maskOpen) == 0 || (cell & maskBomb) != 0 {
					continue;
				}
				if (field[index] & maskCount) != 0 {
					continue
				}

				if revealNeighbors(r, c, index) {
					changed = true
				}
			}
		}
	}
}

void pushReveal(u8 row, u8 column, i16 index) {
	u8 stackSize = revealStackSize
	if stackSize >= REVEAL_STACK_CAPACITY {
		revealStackSize = REVEAL_STACK_OVERFLOW
		return
	}

	revealStackRows[stackSize] = row
	revealStackColumns[stackSize] = column
	*revealStackIndexTop = index
	revealStackIndexTop = revealStackIndexTop + 1
	revealStackSize = stackSize + 1
}

bool revealNeighbors(u8 row, u8 column, i16 index) {
	u8 rowFrom = row
	if rowFrom > 0 {
		rowFrom -= 1
		index -= WIDTH
	}
	u8 rowTo = row + 1
	if rowTo >= HEIGHT {
		rowTo -= 1
	}

	u8 colFrom = column
	if colFrom > 0 {
		colFrom -= 1
		index -= 1
	}
	u8 colTo = column + 1
	if colTo >= WIDTH {
		colTo -= 1
	}
	bool changed = false
	for (u8 r = rowFrom; r <= rowTo; r += 1) {
		for (u8 c = colFrom; c <= colTo; c += 1, index += 1) {
			u8 cell = field[index]
			if (cell & maskOpen) != 0 {
				continue;
			}

			cell = cell | maskOpen
			field[index] = cell
			printCellAt(cell, r, c)
			changed = true
			if (cell & (maskBomb | maskCount)) == 0 && revealStackSize != REVEAL_STACK_OVERFLOW {
				pushReveal(r, c, index)
			}
		}
		index = index - colTo as i16 + colFrom as i16 + WIDTH - 1
	}
	return changed
}

void main() {
	initRandom(7439742);
	clearField();
	initializeScreen();
	setCursor(HEIGHT, 0);
//	printString("Left:");
	u8 col = WIDTH / 2;
	u8 row = HEIGHT / 2;
	i16 bombsLeft = -1
	while (true) {
		if (bombsLeft == 0) {
			printString(" You've cleaned the field!");
			break;
		}

		showCursor(row, col, true)
		i16 chr = getChar();
		showCursor(row, col, false)
		if (chr == ESCAPE) {
			break;
		}

		if (chr == 0x0D) {
			if (bombsLeft < 0) {
				bombsLeft = initField(row, col);
			}
			i16 index = rowColumnToCell(row, col)
			u8 cell = field[index]
			if (cell & maskOpen) == 0 {
				field[index] = cell | maskOpen
			}
			if (cell & maskBomb) != 0 {
				printCellAt(row, col)
				printString("boom! you've lost");
				break;
			}
			maybeRevealAround(row, col);
		}
		// cursor up
		else if (chr == CURSOR_UP) {
			if row > 0 {
				row -= 1
			}
		}
		// cursor down
		else if (chr == CURSOR_DOWN) {
			if row < HEIGHT - 1 {
				row += 1
			}
		}
		// cursor left
		else if (chr == CURSOR_LEFT) {
			if col > 0 {
				col -= 1
			}
		}
		// cursor right
		else if (chr == CURSOR_RIGHT) {
			if col < WIDTH - 1 {
				col += 1
			}
		}
		// space = flag
		else if (chr == 0x20) {
			if (bombsLeft >= 0) {
				i16 index = rowColumnToCell(row, col)
				u8 cell = field[index]
				if (cell & maskOpen) == 0 {
					cell = cell ^ maskFlag;
					if (cell & maskBomb) != 0 {
						if (cell & maskFlag) != 0 {
							bombsLeft -= 1
						}
						else {
							bombsLeft += 1
						}
					}
					field[index] = cell
					printCellAt(cell, row, col)
				}
			}
		}
	}
}

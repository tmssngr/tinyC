#include "io.h"
#include "random.h"

const width = 17;
const height = 20;
const bombRatio = 70;
const bombCount = height * width * bombRatio / 1000;

const maskBomb = 1;
const maskOpen = 2;
const maskFlag = 4;

u8 field[width * height];

i16 rowColumnToCell(u8 row, u8 column) {
	i16 r = (i16)row
	i16 c = (i16)column
	return r * width + c;
}

u8 getBombCountAround(u8 row, u8 column) {
	u8 rowFrom = row
	if rowFrom > 0 {
		rowFrom = row - 1
	}
	u8 rowTo = row + 1
	if rowTo >= height {
		rowTo = rowTo - 1
	}

	u8 colFrom = column
	if colFrom > 0 {
		colFrom = colFrom - 1
	}
	u8 colTo = column + 1
	if colTo >= width {
		colTo = colTo - 1
	}
	
	u8 count = 0;
	i16 index = rowColumnToCell(rowFrom, colFrom)
	for (u8 r = rowFrom; r <= rowTo; r = r + 1) {
		for (u8 c = colFrom; c <= colTo; c = c + 1, index = index + 1) {
			if r == row && c == column {
				continue
			}

			u8 cell = field[index]
			if (cell & maskBomb) != 0 {
				count = count + 1;
			}
		}
		index = index - (i16)colTo + (i16)colFrom + width - 1
	}
	return count;
}

i16 columnToX(u8 column) {
	i16 c = (i16)column
	return (c + 1) * 2
}

void printCellAt(u8 row, u8 column) {
	u8 cell = field[rowColumnToCell(row, column)]
	printCellAt(cell, row, column)
}

void printCellAt(u8 cell, u8 row, u8 column) {
	i16 x = columnToX(column)
	setCursor((i16)row, x)
	printCell(cell, row, column)
}

void printCell(u8 cell, u8 row, u8 column) {
	u8 chr = '.';
	if (cell & maskOpen) != 0 {
		if (cell & maskBomb) != 0 {
			chr = '*';
		}
		else {
			u8 count = getBombCountAround(row, column);
			if (count > 0) {
				chr = '0' + count;
			}
			else {
				chr = ' ';
			}
		}
	}
	else if ((cell & maskFlag) != 0) {
		chr = '#';
	}
	printChar(chr);
}

void printField() {
	setCursor(0i16, 0i16);
	for (u8 row = 0; row < height; row = row + 1) {
		printChar('|');
		for (u8 column = 0; column < width; column = column + 1) {
			printChar(' ');
			u8 cell = field[rowColumnToCell(row, column)]
			printCell(cell, row, column);
		}
		printString(" |\n");
	}
}

void showCursor(u8 row, u8 column, bool show) {
	i16 x = columnToX(column)
	setCursor((i16)row, x - 1)
	u8 chr = ' '
	if show {
		chr = '['
	}
	printChar(chr)
	
	setCursor((i16)row, x + 1)
	if show {
		chr = ']'
	}
	printChar(chr)
}

void printSpaces(i16 i) {
	for (; i > 0; i = i - 1) {
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
		count = count + 1;
		value = value / 10;
		if (value == 0) {
			break;
		}
	}

	return count;
}

i16 getHiddenCount() {
	i16 count = 0;
	for (u8 r = 0; r < height; r = r + 1) {
		for (u8 c = 0; c < width; c = c + 1) {
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

	i16 leftDigits = (i16)getDigitCount(count);
	i16 bombDigits = (i16)getDigitCount(bombCount);
	setCursor(height, 6);
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
	for (i16 i = (i16)width * (i16)height; i > 0; i = i - 1) {
		field[index] = 0
	}
}

void initField(u8 curr_r, u8 curr_c) {
	i16 r = (i16)curr_r
	i16 c = (i16)curr_c
	for (i16 bombs = bombCount; bombs > 0; bombs = bombs - 1) {
		i16 row = random16() % height;
		i16 column = random16() % width;
		if (abs(row    - r) > 1 ||
		    abs(column - c) > 1) {
			field[rowColumnToCell((u8)row, (u8)column)] = maskBomb
		}
	}
}

void maybeRevealAround(u8 row, u8 column) {
	printCellAt(row, column)
	if (getBombCountAround(row, column) != 0) {
		return;
	}

	u8 rowFrom = row
	if rowFrom > 0 {
		rowFrom = row - 1
	}
	u8 rowTo = row + 1
	if rowTo >= height {
		rowTo = rowTo - 1
	}

	u8 colFrom = column
	if colFrom > 0 {
		colFrom = colFrom - 1
	}
	u8 colTo = column + 1
	if colTo >= width {
		colTo = colTo - 1
	}
	i16 index = rowColumnToCell(rowFrom, colFrom)
	for (u8 r = rowFrom; r <= rowTo; r = r + 1) {
		for (u8 c = colFrom; c <= colTo; c = c + 1, index = index + 1) {
			if (r == row && c == column) {
				continue;
			}

			u8 cell = field[index]
			if (cell & maskOpen) != 0 {
				continue;
			}

			field[index] = cell | maskOpen
			maybeRevealAround(r, c);
		}
//		index = index - (i16)colTo + (i16)colFrom + width - 1
		i16 colCount = (i16)(colTo - colFrom + 1)
		index = index - colCount + width
	}
}

void main() {
	initRandom(7439742);
	bool needsInitialize = true;
	clearField();
	printField();
	setCursor(height, 0);
	printString("Left:");
	u8 curr_c = width / 2;
	u8 curr_r = height / 2;
	while (true) {
		if (!needsInitialize) {
			if (printLeft()) {
				printString(" You've cleaned the field!");
				break;
			}
		}

		showCursor(curr_r, curr_c, true)
		i16 chr = getChar();
		showCursor(curr_r, curr_c, false)
		if (chr == ESCAPE) {
			break;
		}

		if (chr == 0x0D) {
			if (needsInitialize) {
				needsInitialize = false;
				initField(curr_r, curr_c);
			}
			i16 index = rowColumnToCell(curr_r, curr_c)
			u8 cell = field[index]
			if (cell & maskOpen) == 0 {
				field[index] = cell | maskOpen
			}
			if (cell & maskBomb) != 0 {
				printCellAt(curr_r, curr_c)
				printString("boom! you've lost");
				break;
			}
			maybeRevealAround(curr_r, curr_c);
		}
		// cursor up
		else if (chr == CURSOR_UP) {
			if curr_r > 0 {
				curr_r = curr_r - 1
			}
		}
		// cursor down
		else if (chr == CURSOR_DOWN) {
			if curr_r < height - 1 {
				curr_r = curr_r + 1
			}
		}
		// cursor left
		else if (chr == CURSOR_LEFT) {
			if curr_c > 0 {
				curr_c = curr_c - 1
			}
		}
		// cursor right
		else if (chr == CURSOR_RIGHT) {
			if curr_c < width - 1 {
				curr_c = curr_c + 1
			}
		}
		// space = flag
		else if (chr == 0x20) {
			if (!needsInitialize) {
				i16 index = rowColumnToCell(curr_r, curr_c)
				u8 cell = field[index]
				if (cell & maskOpen) == 0 {
					cell = cell ^ maskFlag;
					field[index] = cell
					printCellAt(cell, curr_r, curr_c)
				}
			}
		}
	}
}

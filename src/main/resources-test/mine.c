#include "io.h"

const width = 40;
const height = 20;
const bombRatio = 50;
const bombCount = height * width * bombRatio / 1000;

const maskBomb = 1;
const maskOpen = 2;
const maskFlag = 4;

u8 field[width * height];

i16 rowColumnToCell(i16 row, i16 column) {
	return row * width + column;
}

u8 getCell(i16 row, i16 column) {
	return field[rowColumnToCell(row, column)];
}

bool isBomb(u8 cell) {
	return (cell & maskBomb) != 0;
}

bool isOpen(u8 cell) {
	return (cell & maskOpen) != 0;
}

bool isFlag(u8 cell) {
	return (cell & maskFlag) != 0;
}

bool checkCellBounds(i16 row, i16 column) {
	return 0 <= row    && row    < height
	    && 0 <= column && column < width;
}

void setCell(i16 row, i16 column, u8 cell) {
	field[rowColumnToCell(row, column)] = cell;
}

u8 getBombCountAround(i16 row, i16 column) {
	u8 count = 0;
	for (i16 dr = -1; dr <= 1; dr = dr + 1) {
		i16 r = row + dr;
		for (i16 dc = -1; dc <= 1; dc = dc + 1) {
			i16 c = column + dc;
			if (checkCellBounds(r, c)) {
				u8 cell = getCell(r, c);
				if (isBomb(cell)) {
					count = count + 1;
				}
			}
		}
	}
	return count;
}

u8 getSpacer(i16 row, i16 column, i16 rowCursor, i16 columnCursor) {
	if (rowCursor == row) {
		if (columnCursor == column) {
			return '[';
		}
		if (columnCursor == column - 1) {
			return ']';
		}
	}
	return ' ';
}

void printCell(u8 cell, i16 row, i16 column) {
	u8 chr = '.';
	if (isOpen(cell)) {
		if (isBomb(cell)) {
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
	else if (isFlag(cell)) {
		chr = '#';
	}
	printChar(chr);
}

void printField(i16 rowCursor, i16 columnCursor) {
	setCursor(0, 0);
	for (i16 row = 0; row < height; row = row + 1) {
		printChar('|');
		for (i16 column = 0; column < width; column = column + 1) {
			u8 spacer = getSpacer(row, column, rowCursor, columnCursor);
			printChar(spacer);
			u8 cell = getCell(row, column);
			printCell(cell, row, column);
		}
		u8 spacer = getSpacer(row, width, rowCursor, columnCursor);
		printChar(spacer);
		printString("|\n");
	}
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
	for (i16 r = 0; r < height; r = r + 1) {
		for (i16 c = 0; c < width; c = c + 1) {
			u8 cell = getCell(r, c);
			if ((cell & (maskFlag | maskOpen)) == 0) {
				count = count + 1;
			}
		}
	}
	return count;
}

bool printLeft() {
	i16 count = getHiddenCount();

	i16 leftDigits = getDigitCount(count);
	i16 bombDigits = getDigitCount(bombCount);
	printString("Left: ");
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
	for (i16 r = 0; r < height; r = r + 1) {
		for (i16 c = 0; c < width; c = c + 1) {
			setCell(r, c, 0);
		}
	}
}

void initField(i16 curr_r, i16 curr_c) {
	for (i16 bombs = bombCount; bombs > 0; bombs = bombs - 1) {
		i16 row = (i16)(random() % height);
		i16 column = (i16)(random() % width);
		if (abs(row    - curr_r) > 1
		 || abs(column - curr_c) > 1) {
			setCell(row, column, maskBomb);
		}
	}
}

void maybeRevealAround(i16 row, i16 column) {
	if (getBombCountAround(row, column) != 0) {
		return;
	}

	for (i16 dr = -1; dr <= 1; dr = dr + 1) {
		i16 r = row + dr;
		for (i16 dc = -1; dc <= 1; dc = dc + 1) {
			if (dr == 0 && dc == 0) {
				continue;
			}

			i16 c = column + dc;
			if (!checkCellBounds(r, c)) {
				continue;
			}

			u8 cell = getCell(r, c);
			if (isOpen(cell)) {
				continue;
			}

			setCell(r, c, cell | maskOpen);
			maybeRevealAround(r, c);
		}
	}
}

void main() {
	initRandom(7439742);
	bool needsInitialize = true;
	clearField();
	i16 curr_c = width / 2;
	i16 curr_r = height / 2;
	while (true) {
		printField(curr_r, curr_c);
		if (!needsInitialize) {
			if (printLeft()) {
				printString(" You've cleaned the field!");
				break;
			}
		}

		i16 chr = getChar();
		if (chr == 0x1b) {
			break;
		}

		// cursor up
		if (chr == 0xE048) {
			curr_r = (curr_r + height - 1) % height;
		}
		// cursor down
		else if (chr == 0xE050) {
			curr_r = (curr_r + 1) % height;
		}
		// cursor left
		else if (chr == 0xE04B) {
			curr_c = (curr_c + width - 1) % width;
		}
		// cursor left
		else if (chr == 0xE04B) {
			curr_c = (curr_c + width - 1) % width;
		}
		// cursor right
		else if (chr == 0xE04D) {
			curr_c = (curr_c + 1) % width;
		}
		// space = flag
		else if (chr == 0x20) {
			if (!needsInitialize) {
				u8 cell = getCell(curr_r, curr_c);
				if (!isOpen(cell)) {
					cell = cell ^ maskFlag;
					setCell(curr_r, curr_c, cell);
				}
			}
		}
		else if (chr == 0x0D) {
			if (needsInitialize) {
				needsInitialize = false;
				initField(curr_r, curr_c);
			}
			u8 cell = getCell(curr_r, curr_c);
			if (!isOpen(cell)) {
				setCell(curr_r, curr_c, cell | maskOpen);
			}
			if (isBomb(cell)) {
				printField(curr_r, curr_c);
				printString("boom! you've lost");
				break;
			}
			maybeRevealAround(curr_r, curr_c);
		}
	}
}

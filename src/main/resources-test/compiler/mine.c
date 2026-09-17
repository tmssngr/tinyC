#include "io.h"
#include "random.h"

const width = 17;
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
	return 0 <= row    && row    < height &&
	       0 <= column && column < width;
}

void setCell(i16 row, i16 column, u8 cell) {
	field[rowColumnToCell(row, column)] = cell;
}

u8 getBombCountAround(i16 row, i16 column) {
	u8 count = 0
	for (i16 dr = -1; dr <= 1; dr = dr + 1) {
		i16 r = row + dr
		if r < 0 || r >= height {
			continue
		}

		for (i16 dc = -1; dc <= 1; dc = dc + 1) {
			i16 c = column + dc;
			if c < 0 || c >= width {
				continue
			}

			u8 cell = getCell(r, c);
			if (isBomb(cell)) {
				count = count + 1;
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
	u8 chr = '.'
	if isFlag(cell) {
		chr = '#';
	}
	else if isBomb(cell) {
		chr = '*';
	}
	else {
		u8 count = getBombCountAround(row, column);
		if count == 0 && isOpen(cell) {
			chr = ' ';
		}
		else {
			chr = '0' + count;
		}
	}
	printChar(chr);
}

void printCellAt(i16 row, i16 column) {
	u8 cell = getCell(row, column)
	printCellAt(cell, row, column)
}

void printCellAt(u8 cell, i16 row, i16 column) {
	setCursor(row, getX(column))
	printCell(cell, row, column)
}

void printField() {
	setCursor(0i16, 0i16);
	for (i16 row = 0; row < height; row = row + 1) {
		printChar('|');
		for (i16 column = 0; column < width; column = column + 1) {
			printChar(' ');
			u8 cell = getCell(row, column);
			printCell(cell, row, column);
		}
		printString(" |\n");
	}
}

i16 getX(i16 column) {
	return (column + 1) * 2;
}

void printCursor(i16 row, i16 column, bool show) {
	i16 x = getX(column);
	setCursor(row, x - 1);
	if (show) {
		printChar('[');
	}
	else {
		printChar(' ');
	}
	setCursor(row, x + 1);
	if (show) {
		printChar(']');
	}
	else {
		printChar(' ');
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
	for (i16 r = 0; r < height; r = r + 1) {
		for (i16 c = 0; c < width; c = c + 1) {
			setCell(r, c, 0);
		}
	}
}

void initField(i16 curr_r, i16 curr_c) {
	for (i16 bombs = bombCount; bombs > 0; bombs = bombs - 1) {
		i16 row = random16() % height;
		i16 column = random16() % width;
		if (abs(row    - curr_r) > 1 ||
		    abs(column - curr_c) > 1) {
			setCell(row, column, maskBomb);
		}
	}
}

void maybeRevealAround(i16 row, i16 column) {
	printCellAt(row, column)
	if getBombCountAround(row, column) != 0 {
		return;
	}

	i16 left = revealToLeft(row, column)
	i16 right = revealToRight(row, column)

	i16 prevRow = row - 1
	if prevRow >= 0 {
		revealAround(prevRow, left, right, true)
	}
	i16 nextRow = row + 1
	if nextRow < height {
		revealAround(nextRow, left, right, false)
	}
}

void revealAround(i16 row, i16 prevLeft, i16 prevRight, bool upwards) {
	i16 left = revealToLeft(row, prevLeft)
	i16 right = revealToRight(row, prevLeft)

	while right < prevRight {
		right = right + 1
		isRevealCell(row, right)
	}
}

u8 isRevealCell(i16 row, i16 column) {
	u8 cell = getCell(row, column)
	if isOpen(cell) {
		return 0
	}
	
	cell = cell | maskOpen
	setCell(row, column, cell)
	printCellAt(cell, row, column)
	return getBombCountAround(row, column) + 1
}


i16 revealToLeft(i16 row, i16 column) {
	isRevealCell(row, column)
	while true {
		column = column - 1
		if column < 0 {
			break
		}

		if isRevealCell(row, column) != 1 {
			break
		}
	}
	return column + 1
}

i16 revealToRight(i16 row, i16 column) {
	isRevealCell(row, column)
	while true {
		column = column + 1
		if column >= width {
			break
		}

		if isRevealCell(row, column) != 1 {
			break
		}
	}
	return column - 1
}

void printCellDetails(i16 row, i16 column) {
	setCursor(height, 10)
	printInt(row)
	printChar('x')
	printInt(column)
	printChar(':')
	printUint(getCell(row, column))
	printChar(' ')
}

void main() {
	initRandom(7439742);
	bool needsInitialize = true;
	clearField();
	i16 curr_c = (i16)(width / 2);
	i16 curr_r = (i16)(height / 2);
	printField();
	setCursor(height, 0);
	printString("Left:");
	while (true) {
		if (!needsInitialize) {
			if (printLeft()) {
				printString(" You've cleaned the field!");
				break;
			}
		}

		printCellDetails(curr_r, curr_c)
		printCursor(curr_r, curr_c, true);
		i16 chr = getChar();
		printCursor(curr_r, curr_c, false);
		if (chr == ESCAPE) {
			break;
		}

		// cursor up
		if (chr == CURSOR_UP) {
			curr_r = (curr_r + height - 1) % height;
		}
		// cursor down
		else if (chr == CURSOR_DOWN) {
			curr_r = (curr_r + 1) % height;
		}
		// cursor left
		else if (chr == CURSOR_LEFT) {
			curr_c = (curr_c + width - 1) % width;
		}
		// cursor right
		else if (chr == CURSOR_RIGHT) {
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
				printField();
			}
			u8 cell = getCell(curr_r, curr_c);
			if (!isOpen(cell)) {
				setCell(curr_r, curr_c, cell | maskOpen);
			}
			if (isBomb(cell)) {
				printField();
				printString("boom! you've lost");
				break;
			}
			maybeRevealAround(curr_r, curr_c);
		}
	}
}

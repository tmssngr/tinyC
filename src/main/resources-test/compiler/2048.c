#include "io.h"
#include "random.h"

#ifdef Z8
const CLEAR_SCREEN = true;
#else
const CLEAR_SCREEN = false;
#endif

const BOARD_SIZE = 4;
const BOARD_CELLS = BOARD_SIZE * BOARD_SIZE;
const WIN_TILE = 11;
const BOARD_TOP = 3;
const BOARD_LEFT = 1;
const TILE_WIDTH = 8;
const TILE_HEIGHT = 3;
const TILE_COLUMN_STEP = TILE_WIDTH + 1;
const TILE_ROW_STEP = TILE_HEIGHT + 1;
const BOARD_WIDTH = BOARD_SIZE * TILE_COLUMN_STEP - 1;
const BOARD_HEIGHT = BOARD_SIZE * TILE_ROW_STEP - 1;

const MOVE_LEFT = 0;
const MOVE_RIGHT = 1;
const MOVE_UP = 2;
const MOVE_DOWN = 3;
const MOVE_NONE = 0xFF;
const STEP_RIGHT = 0xFF;
const STEP_DOWN = 0xFC;

const STATE_PLAYING = 0;
const STATE_WON = 1;
const STATE_LOST = 2;

u8 tiles[BOARD_CELLS];
i32 score;
u8 gameState;

i32 tileValue(u8 exponent) {
	i32 value = 1;
	for (u8 index = 0; index < exponent; index += 1) {
		value <<= 1;
	}
	return value;
}

void spawnTile() {
	u8 emptyCount = 0;
	for (u8 index = 0; index < BOARD_CELLS; index += 1) {
		if (tiles[index] == 0) {
			emptyCount += 1;
		}
	}
	if (emptyCount == 0) {
		return;
	}

	u8 chosen = (random16() % emptyCount as i16) as u8;
	for (u8 index = 0; index < BOARD_CELLS; index += 1) {
		if (tiles[index] != 0) {
			continue;
		}
		if (chosen == 0) {
			u8 tile = 1;
			if (random16() % 10) == 0 {
				tile = 2;
			}
			tiles[index] = tile;
			return;
		}
		chosen -= 1;
	}
}

bool slideLine(u8 first, u8 step) {
	u8 source = first;
	u8 target = first;
	bool previousMerged = false;
	bool moved = false;
	for (u8 position = 0; position < BOARD_SIZE; position += 1) {
		u8* sourceTile = &tiles[source];
		u8 tile = *sourceTile;
		if (tile != 0) {
			*sourceTile = 0;
			bool merged = false;
			if (target != first && !previousMerged) {
				u8 previous = target - step;
				u8* previousTile = &tiles[previous];
				if (*previousTile == tile) {
					u8 nextTile = tile + 1;
					*previousTile = nextTile;
					score = score + tileValue(nextTile);
					if (nextTile == WIN_TILE) {
						gameState = STATE_WON;
					}
					merged = true;
					previousMerged = true;
					moved = true;
				}
			}
			if (!merged) {
				tiles[target] = tile;
				if (target != source) {
					moved = true;
				}
				target = target + step;
				previousMerged = false;
			}
		}
		source += step;
	}
	return moved;
}

bool slide(u8 direction) {
	bool moved = false;
	for (u8 line = 0; line < BOARD_SIZE; line += 1) {
		u8 first = line << 2;
		u8 step = 1;
		if (direction == MOVE_RIGHT) {
			first += 3;
			step = STEP_RIGHT;
		}
		else if (direction == MOVE_UP) {
			first = line;
			step = 4;
		}
		else if (direction == MOVE_DOWN) {
			first = line + 12;
			step = STEP_DOWN;
		}
		if (slideLine(first, step)) {
			moved = true;
		}
	}
	return moved;
}

bool canMove() {
	for (u8 index = 0; index < BOARD_CELLS; index += 1) {
		u8 tile = tiles[index];
		if (tile == 0) {
			return true;
		}
		if ((index & 3) != 3 && tiles[index + 1] == tile) {
			return true;
		}
		if (index < 12 && tiles[index + 4] == tile) {
			return true;
		}
	}
	return false;
}

void printTile(u8 exponent) {
	if (exponent == 0) {
		printString("      ");
	}
	else if (exponent == 1) {
		printString("  2   ");
	}
	else if (exponent == 2) {
		printString("  4   ");
	}
	else if (exponent == 3) {
		printString("  8   ");
	}
	else if (exponent == 4) {
		printString("  16  ");
	}
	else if (exponent == 5) {
		printString("  32  ");
	}
	else if (exponent == 6) {
		printString("  64  ");
	}
	else if (exponent == 7) {
		printString(" 128  ");
	}
	else if (exponent == 8) {
		printString(" 256  ");
	}
	else if (exponent == 9) {
		printString(" 512  ");
	}
	else if (exponent == 10) {
		printString(" 1024 ");
	}
	else if (exponent == WIN_TILE) {
		printString(" 2048 ");
	}
	else {
		printString("  ?   ");
	}
}

void drawTileAt(i16 row, i16 column, u8 exponent) {
	if (exponent == 0) {
		return;
	}
	setCursor(row, column);
	printString("+------+");
	setCursor(row + 1, column);
	printChar('|');
	printTile(exponent);
	printChar('|');
	setCursor(row + 2, column);
	printString("+------+");
}

void drawFrame() {
	if CLEAR_SCREEN {
		printChar(0x0C);
	}
	setCursor(1i16, 0i16);
	printString("Arrows/WASD  R restart  Esc quit");
}

void clearBoard() {
	for (i16 row = 0; row < BOARD_HEIGHT; row += 1) {
		setCursor(row + BOARD_TOP, BOARD_LEFT as i16);
		printString("                                   ");
	}
}

void drawBoard() {
	clearBoard();
	u8 index = 0;
	i16 row = BOARD_TOP;
	for (u8 boardRow = 0; boardRow < BOARD_SIZE; boardRow += 1) {
		i16 column = BOARD_LEFT;
		for (u8 boardColumn = 0; boardColumn < BOARD_SIZE; boardColumn += 1) {
			drawTileAt(row, column, tiles[index]);
			index += 1;
			column += TILE_COLUMN_STEP;
		}
		row += TILE_ROW_STEP;
	}
}

void drawScore() {
	setCursor(0i16, 0i16);
	printString("2048  Score: ");
	printUint(score);
	printString("          ");
}

void drawStatus() {
	setCursor((BOARD_TOP + BOARD_HEIGHT + 1) as i16, 0i16);
	printString("                                      ");
	setCursor((BOARD_TOP + BOARD_HEIGHT + 1) as i16, 0i16);
	if (gameState == STATE_WON) {
		printString("2048! Press R to play again.");
	}
	else if (gameState == STATE_LOST) {
		printString("No moves left. Press R to restart.");
	}
}

void newGame() {
	for (u8 index = 0; index < BOARD_CELLS; index += 1) {
		tiles[index] = 0;
	}
	score = 0;
	gameState = STATE_PLAYING;
	spawnTile();
	spawnTile();
	drawBoard();
	drawScore();
	drawStatus();
	setCursor(21i16, 0i16);
}

void main() {
	initRandom(7439742);
	drawFrame();
	newGame();
	while (true) {
		i16 key = getChar();
		if (key == ESCAPE) {
			break;
		}
		if (key == 'r' || key == 'R') {
			newGame();
			continue;
		}
		if (gameState != STATE_PLAYING) {
			continue;
		}

		u8 direction = MOVE_NONE;
		if (key == CURSOR_LEFT || key == 'a' || key == 'A') {
			direction = MOVE_LEFT;
		}
		else if (key == CURSOR_RIGHT || key == 'd' || key == 'D') {
			direction = MOVE_RIGHT;
		}
		else if (key == CURSOR_UP || key == 'w' || key == 'W') {
			direction = MOVE_UP;
		}
		else if (key == CURSOR_DOWN || key == 's' || key == 'S') {
			direction = MOVE_DOWN;
		}
		if (direction == MOVE_NONE || !slide(direction)) {
			continue;
		}

		spawnTile();
		if (gameState == STATE_PLAYING && !canMove()) {
			gameState = STATE_LOST;
		}
		drawBoard();
		drawScore();
		if (gameState != STATE_PLAYING) {
			drawStatus();
		}
		setCursor(21i16, 0i16);
	}
}

#include "io.h"
#include "random.h"

#ifdef Z8
const CLEAR_SCREEN = true;
const ANIMATION_STEPS = 4;
#else
const CLEAR_SCREEN = false;
const ANIMATION_STEPS = 8;
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
const BOARD_CHARACTERS = BOARD_WIDTH * BOARD_HEIGHT;

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
u8 spawnedTileIndex;
u8 moveTiles[BOARD_CELLS];
u8 moveTargets[BOARD_CELLS];
u8 boardFrame[BOARD_CHARACTERS];
u8 displayedFrame[BOARD_CHARACTERS];
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
			spawnedTileIndex = index;
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
					moveTargets[source] = previous;
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
				moveTargets[source] = target;
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
	for (u8 index = 0; index < BOARD_CELLS; index += 1) {
		moveTiles[index] = tiles[index];
		moveTargets[index] = index;
	}
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

u8* tileText(u8 exponent) {
	if (exponent == 0) {
		return "      ";
	}
	else if (exponent == 1) {
		return "   2  ";
	}
	else if (exponent == 2) {
		return "   4  ";
	}
	else if (exponent == 3) {
		return "   8  ";
	}
	else if (exponent == 4) {
		return "  16  ";
	}
	else if (exponent == 5) {
		return "  32  ";
	}
	else if (exponent == 6) {
		return "  64  ";
	}
	else if (exponent == 7) {
		return "  128 ";
	}
	else if (exponent == 8) {
		return "  256 ";
	}
	else if (exponent == 9) {
		return "  512 ";
	}
	else if (exponent == 10) {
		return " 1024 ";
	}
	else if (exponent == WIN_TILE) {
		return " 2048 ";
	}
	return "  ?   ";
}

void drawTileRow(i16 offset, u8* text) {
	for (u8 index = 0; index < TILE_WIDTH; index += 1) {
		boardFrame[offset] = text[index];
		offset += 1;
	}
}

void drawTileAt(i16 row, i16 column, u8 exponent) {
	if (exponent == 0) {
		return;
	}
	i16 offset = (row - BOARD_TOP) * BOARD_WIDTH + column - BOARD_LEFT;
	drawTileRow(offset, "+------+");
	offset += BOARD_WIDTH;
	boardFrame[offset] = '|';
	boardFrame[offset + TILE_WIDTH - 1] = '|';
	u8* text = tileText(exponent);
	for (u8 index = 0; index < TILE_WIDTH - 2; index += 1) {
		boardFrame[offset + index as i16 + 1] = text[index];
	}
	drawTileRow(offset + BOARD_WIDTH, "+------+");
}

void drawFrame() {
	if CLEAR_SCREEN {
		printChar(0x0C);
	}
	setCursor(1i16, 0i16);
	printString("Arrows/WASD  R restart  Esc quit");
}

void clearBoard() {
	for (i16 offset = 0; offset < BOARD_CHARACTERS; offset += 1) {
		boardFrame[offset] = ' ';
	}
}

void presentBoard() {
	i16 offset = 0;
	for (i16 row = 0; row < BOARD_HEIGHT; row += 1) {
		bool printing = false;
		for (i16 column = 0; column < BOARD_WIDTH; column += 1) {
			u8 character = boardFrame[offset];
			if (character != displayedFrame[offset]) {
				if (!printing) {
					setCursor(row + BOARD_TOP, column + BOARD_LEFT);
					printing = true;
				}
				printChar(character);
				displayedFrame[offset] = character;
			}
			else {
				printing = false;
			}
			offset += 1;
		}
	}
	setCursor(21i16, 0i16);
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
	presentBoard();
}

#ifdef Z8
void waitFrame() asm {
	"ld   r0, #0"
	".loop:"
	"djnz r0, .loop"
	"ret"
}
#else
  #ifdef __WINDOWS
void waitFrame() asm {
	"sub  rsp, 28h"
	"mov  ecx, 20"
	"call [Sleep]"
	"add  rsp, 28h"
	"ret"
}
  #else
void waitFrame() asm {
	"sub  rsp, 10h"
	"mov  qword [rsp], 0"
	"mov  qword [rsp+8], 20000000"
	"mov  rdi, rsp"
	"xor  esi, esi"
	"mov  eax, 35"
	"syscall"
	"add  rsp, 10h"
	"ret"
}
  #endif
#endif

void animateSlide() {
	for (i16 frame = 1; frame <= ANIMATION_STEPS; frame += 1) {
		i16 remaining = ANIMATION_STEPS;
		remaining -= frame;
		clearBoard();
		for (u8 source = 0; source < BOARD_CELLS; source += 1) {
			u8 exponent = moveTiles[source];
			if (exponent == 0) {
				continue;
			}
			u8 target = moveTargets[source];
			i16 sourceRow = (source >> 2) as i16 * TILE_ROW_STEP;
			i16 sourceColumn = (source & 3) as i16 * TILE_COLUMN_STEP;
			i16 targetRow = (target >> 2) as i16 * TILE_ROW_STEP;
			i16 targetColumn = (target & 3) as i16 * TILE_COLUMN_STEP;
			i16 row = (sourceRow * remaining + targetRow * frame) / ANIMATION_STEPS;
			i16 column = (sourceColumn * remaining + targetColumn * frame) / ANIMATION_STEPS;
			drawTileAt(row + BOARD_TOP, column + BOARD_LEFT, exponent);
		}
		presentBoard();
		waitFrame();
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
		i16 row = (spawnedTileIndex >> 2) as i16 * TILE_ROW_STEP + (BOARD_TOP + TILE_HEIGHT / 2) as i16;
		i16 column = (spawnedTileIndex & 3) as i16 * TILE_COLUMN_STEP + (BOARD_LEFT + TILE_WIDTH / 2) as i16;
		setCursor(row, column);
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
		else {
			continue
		}
		if !slide(direction) {
			continue;
		}

		animateSlide();
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
	setCursor(21i16, 0i16);
}

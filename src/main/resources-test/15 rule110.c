#include "io.h"

// https://gist.github.com/rexim/c595009436f87ca076e7c4a2fb92ce10

const BOARD_CAP = 30;

u8 board[BOARD_CAP];

void printBoard() {
	printChar('|');
	for (u8 i = 0; i < BOARD_CAP; i = i + 1) {
		if (board[i] == 0) {
			printChar(' ');
		}
		else {
			printChar('*');
		}
	}
	printString("|\n");
}

void main() {
	for (u8 i = 0; i < BOARD_CAP; i = i + 1) {
		board[i] = 0;
	}
	board[BOARD_CAP - 1] = 1;

	printBoard();

	for (u8 i = 0; i < BOARD_CAP - 2; i = i + 1) {
		u8 pattern = (board[0] << 1) | board[1];
		for (u8 j = 1; j < BOARD_CAP - 1; j = j + 1) {
			pattern = ((pattern << 1) & 7) | board[j + 1];
			board[j] = (110 >> pattern) & 1;
		}
		printBoard();
	}
}

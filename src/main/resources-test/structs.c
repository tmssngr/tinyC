#include "io.h"

typedef Pos struct (u8 x, u8 y);

typedef ListEntry struct (u8 value, ListEntry* next);

void main() {
	Pos pos;
	pos.x = 1;
	pos.y = pos.x + 1;
	printIntLf(pos.x);
	printIntLf(pos.y);
	u8* x = &pos.x;
	printIntLf(*x);
}

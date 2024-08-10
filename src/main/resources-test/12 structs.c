typedef Pos (u8 x, u8 y);

typedef ListEntry(u8 value, ListEntry* next);

void main() {
	Pos pos;
	print(pos.y);
	pos.x = 1;
	pos.y = pos.x;
	print(pos.y);
	u8* x = &pos.x;
	print(*x);
}

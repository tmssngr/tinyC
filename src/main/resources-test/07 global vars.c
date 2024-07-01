u8 space = 0x20;
u8 next = '?';
u8* ptrToSpace = &space;

void main() {
	ptrToSpace = ptrToSpace + 1;
	print(*ptrToSpace);
}

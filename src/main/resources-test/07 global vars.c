i16 space = 0x20;
i16 next = '?';
i16* ptrToSpace = &space;

void main() {
	ptrToSpace = ptrToSpace + 1;
	print(*ptrToSpace);
}

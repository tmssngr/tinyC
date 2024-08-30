#include "x86_64.h"

i16 space = 0x20;
i16 next = '?';
i16* ptrToSpace = &space;

void main() {
	printIntLf(next);
	ptrToSpace = ptrToSpace + 1;
	printIntLf(*ptrToSpace);
}

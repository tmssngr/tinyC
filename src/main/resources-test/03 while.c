#include "x86_64.h"

void main() {
	u8 i = 5;
	while (i > 0) {
		printIntLf(i);
		i = i - 1;
	}

	while (true) {
		printIntLf(i);
		i = i + 1;
		if (i < 5) {
			continue;
		}
		break;
	}

	while (true) {
		return;
	}
}

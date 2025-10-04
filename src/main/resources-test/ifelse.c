#include "io.h"

void main() {
	i16 a = 1;
	if (a > 0) {
		printIntLf(a);
	}
	else {
		a = -a;
		printIntLf(a);
	}
}

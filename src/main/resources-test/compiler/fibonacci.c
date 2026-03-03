#include "io.h"

void main() {
	i16 a = 0;
	i16 b = 1;
	while (b < 1000) {
	  b = b + a;
	  a = b - a;
	  printIntLf(a);
	}
}

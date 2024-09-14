#include "x86_64.h"

void main() {
	printString("< (signed)\n");
	i16 a = 1;
	i16 b = 2;
	printIntLf(a < b);
	printIntLf(b < a);

	printString("< (unsigned)\n");
	u8 c = 0;
	u8 d = 0x80;
	printIntLf(c < d);
	printIntLf(d < c);

	printString("<= (signed)\n");
	printIntLf(a <= b);
	printIntLf(b <= a);

	printString("<= (unsigned)\n");
	printIntLf(c <= d);
	printIntLf(d <= c);

	printString("==\n");
	printIntLf(a == b);
	printIntLf(b == a);

	printString("!=\n");
	printIntLf(a != b);
	printIntLf(b != a);

	printString(">= (signed)\n");
	printIntLf(a >= b);
	printIntLf(b >= a);

	printString(">= (unsigned)\n");
	printIntLf(c >= d);
	printIntLf(d >= c);

	printString("> (signed)\n");
	printIntLf(a > b);
	printIntLf(b > a);

	printString("> (unsigned)\n");
	printIntLf(c > d);
	printIntLf(d > c);
}

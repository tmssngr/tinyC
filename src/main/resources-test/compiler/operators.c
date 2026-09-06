#include "io.h"

bool getTrue()  { printString(" true");  return true;  }
bool getFalse() { printString(" false"); return false; }

void printPass()  { printString(" -> pass "); }
void printError() { printString(" -> ERROR "); }

void logicNot() {
	printString("\nLogic-!:\n");
	bool t = true;
	bool f = false;
	if (!getFalse()) { printPass(); } else { printError(); }
	printIntLf(!f);
	if (!getTrue()) { printError(); } else { printPass(); }
	printIntLf(!t);
}

void logicAnd() {
	printString("\nLogic-&&:\n");
	bool t = true;
	bool f = false;
	if (getFalse() && getFalse()) { printError(); } else { printPass(); }
	printIntLf(f && f);
	if (getFalse() && getTrue()) { printError(); } else { printPass(); }
	printIntLf(f && t);
	if (getTrue() && getFalse()) { printError(); } else { printPass(); }
	printIntLf(t && f);
	if (getTrue() && getTrue()) { printPass(); } else { printError(); }
	printIntLf(t && t);

	if (!(getFalse() && getFalse())) { printPass(); } else { printError(); }
	printIntLf(!(f && f));
	if (!(getFalse() && getTrue())) { printPass(); } else { printError(); }
	printIntLf(!(f && t));
	if (!(getTrue() && getFalse())) { printPass(); } else { printError(); }
	printIntLf(!(t && f));
	if (!(getTrue() && getTrue())) { printError(); } else { printPass(); }
	printIntLf(!(t && t));
}

void logicOr() {
	printString("\nLogic-||:\n");
	bool t = true;
	bool f = false;
	if (getFalse() || getFalse()) { printError(); } else { printPass(); }
	printIntLf(f || f);
	if (getFalse() || getTrue()) { printPass(); } else { printError(); }
	printIntLf(f || t);
	if (getTrue() || getFalse()) { printPass(); } else { printError(); }
	printIntLf(t || f);
	if (getTrue() || getTrue()) { printPass(); } else { printError(); }
	printIntLf(t || t);
}

void main() {
	printString("Bit-&:\n");
	i16 a = 0;
	i16 b = 1;
	i16 c = 2;
	i16 d = 3;
	bool t = true;
	bool f = false;
	printIntLf(a & a);
	printIntLf(a & b);
	printIntLf(b & a);
	printIntLf(b & b);
	printString("\nBit-|:\n");
	printIntLf(a | a);
	printIntLf(a | b);
	printIntLf(b | a);
	printIntLf(b | b);
	printString("\nBit-^:\n");
	printIntLf(a ^ a);
	printIntLf(a ^ c);
	printIntLf(b ^ a);
	printIntLf(b ^ c);
	logicNot();
	logicAnd();
	logicOr();

	if (!(getTrue() && getTrue()) || !(getFalse() && getFalse())) {
		printPass();
	}
	else {
		printError();
	}
	printIntLf(!(t && t) || !(f && f));

	printString("\n\nmisc:\n");
	u8 b10 = 0b1010;
	u8 b6 = 0b0110;
	u8 b1 = 0b0001;
	printIntLf(b10 & b6 | b1);
	printIntLf(b == c || c < d);
	printIntLf(b == c && c < d);
	printIntLf(-1);
	printIntLf(-b);
	printIntLf(~b1);
}

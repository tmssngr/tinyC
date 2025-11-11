#include <windows.h>

HANDLE hStdOut;

void printUint(int number) {
	const char buffer[20];
	int pos = 20;
	while (TRUE) {
		pos = pos - 1;
		int remainder = number % 10;
		number = number / 10;
		char digit = (char)remainder + '0';
		buffer[pos] = digit;
		if (number == 0) {
			break;
		}
	}
    WriteFile(hStdOut, &buffer[pos], 20 - pos, NULL, NULL);
}

int main(void) {
    hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
    if (hStdOut == INVALID_HANDLE_VALUE) {
        return 1;
    }

	printUint(1000);

    return 0;
}

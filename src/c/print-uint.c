#if defined(_WIN32)
    #include <windows.h>
    HANDLE hStdOut;

    void writeStd(const char* buffer, size_t length) {
        WriteFile(hStdOut, buffer, length, NULL, NULL);
    }

#else
    #include <unistd.h>

    void writeStd(const char* buffer, size_t length) {
        write(1, buffer, length);
    }

    const int TRUE = 1;
#endif

void printUint(int number) {
	char buffer[20];
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
    writeStd(&buffer[pos], 20 - pos);
}

int main(void) {
#if defined(_WIN32)
    hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
    if (hStdOut == INVALID_HANDLE_VALUE) {
        return 1;
    }
#endif

	printUint(1000);

    return 0;
}

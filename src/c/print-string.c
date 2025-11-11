#include <windows.h>

int main(void) {
    HANDLE hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
    if (hStdOut == INVALID_HANDLE_VALUE) {
        return 1;
    }

    const char message[] = "Hello, World!\r\n\0";

    if (!WriteFile(hStdOut, message, sizeof(message) - 1, NULL, NULL)) {
        return 1;
    }

    return 0;
}

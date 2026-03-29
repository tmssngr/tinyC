#include <termios.h>
#include <stdio.h>
#include <unistd.h>  // For STDIN_FILENO (0)

static struct termios oldt, newt;

void init_termios(int echo) {
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~ICANON;
    newt.c_lflag &= echo ? ECHO : ~ECHO;
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
}

void reset_termios(void) {
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
}

char getch(int echo) {
    char ch;
    init_termios(echo);
    ch = getchar();
    reset_termios();
    return ch;
}

int main() {
    printf("Press any key...");
    char c = getch(0);  // No echo
    printf("\nGot: %d\n", (int)c);
    return 0;
}

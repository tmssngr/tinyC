#include "x86_64.h"

void main() {
    printIntLf(1 < 2);
    printIntLf(2 < 1);

    printIntLf(1 <= 2);
    printIntLf(2 <= 1);

    printIntLf(1 == 2);

    printIntLf(1 != 2);

    printIntLf(1 >= 2);
    printIntLf(2 >= 1);

    printIntLf(1 > 2);
    printIntLf(2 > 1);
}

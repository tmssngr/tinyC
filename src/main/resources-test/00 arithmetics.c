#include "x86_64.h"

void main() {
    i16 foo = 4 * 3 + 2*5;
    i16 bar = foo * foo;
    foo = 1;
    printIntLf(bar + foo);
    foo = (1 + 2) * (3 + 4);
    printIntLf(foo);
    i16 bazz;
    printIntLf(bazz);

    printIntLf(1000/10);
    printIntLf(1000 % 256);
}

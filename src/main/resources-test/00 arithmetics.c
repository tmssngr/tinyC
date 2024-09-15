#include "io.h"

void main() {
    i16 foo = 4 * 3 + 2*5;
    i16 bar = foo * foo;
    foo = 1;
    printIntLf(bar + foo);
    foo = (1 + 2) * (3 + 4);
    printIntLf(foo);
    i16 bazz;
    printIntLf(bazz);

    i16 a = 1000;
    i16 b = 10;
    printIntLf(a / b);
    printIntLf(a % 256);

    a = 10;
    b = 1;
    printIntLf(a >> b);
    a = 9;
    b = 2;
    printIntLf(a >> b);
    a = 1;
    printIntLf(a << b);
}

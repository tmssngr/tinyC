#include "io.h"

u8 chars[256];

void main() {
  u8 chr = ' ';
  chars[0] = chr;
  chars[1] = chars[0] + 1;
  chars[1+1] = chars[1] + 2;
  u8 result = chars[2];
  printIntLf(result);
}

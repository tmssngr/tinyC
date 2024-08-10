#include "x86_64.h"

void main() {
  for (u8 i = 250; i != 2; i = i + 1) {
    printIntLf(i);
  }

  i16 v = 260;
  printIntLf((u8)v);
}

#include "io.h"

void main() {
  for (u8 i = 250; i != 2; i += 1) {
    printIntLf(i);
  }

  i16 v = 260;
  printIntLf(v as u8);
}

void printString(u8* str) asm {
	"ld   r2, r0"
	"ld   r3, r1"
	"jr   .loop"
	".print:"
	"call printChar_Pu8"
	"incw r2"
	".loop:"
	"lde  r0, @rr2"
	"or   r0, r0"
	"jr   nz, .print"
	"ret"
}

void printChar(u8 chr) asm {
	"cp    r0, #%0a"
	"jr    ne, .1"
	"ld    r0, #%0d"
	".1:"
	"ld    %15, r0"
	"jp    %0818"
}

void printUint(u8 number) {
	printUint((i32)number);
}

void printUint(i16 number) {
	printUint((i32)number);
}

void printUint(i32 number) asm {
	"ld   r4, #1"
	"ld   r5, #%28"
	"ld   r6, #8"
	".push:"
	"push @r5"
	"inc  r5"
	"djnz r6, .push"
	"; result"
	"clr     r11"
	"clr     r12"
	"clr     r13"
	"clr     r14"
	"clr     r15"
	"; summand (bcd-shifted power of 2)"
	"clr     r6"
	"clr     r7"
	"clr     r8"
	"clr     r9"
	"ld      r10, #1"
	"; counter"
	"ld      r5, #%20"
	".1:"
	"sra     r0"
	"rrc     r1"
	"rrc     r2"
	"rrc     r3"
	"jr      nc, .2"
	"add     r15, r10"
	"da      r15"
	"adc     r14, r9"
	"da      r14"
	"adc     r13, r8"
	"da      r13"
	"adc     r12, r7"
	"da      r12"
	"adc     r11, r6"
	"da      r11"
	".2:"
	"add     r10, r10"
	"da      r10"
	"adc     r9, r9"
	"da      r9"
	"adc     r8, r8"
	"da      r8"
	"adc     r7, r7"
	"da      r7"
	"adc     r6, r6"
	"da      r6"
	"djnz    r5, .1"

	"ld      r6, #%2b"
	"; counter"
	"ld      r7, #10"
	".loop:"
	"ld      r5, @r6"
	"tm      r7, #1"
	"jr      nz, .4"
	"swap    r5"
	".4:"
	"and     r5, #%0f"
	"or      r4, r4"
	"jr      z, .5"
	"cp      r7, #1"
	"jr      eq, .5"
	"or      r5, r5"
	"jr      z, .6"
	"clr     r4"
	".5:"
	"ld      %15, r5"
	"add     %15, #'0'"
	"call    %0818"
	".6:"
	"tm      r7, #1"
	"jr      z, .7"
	"inc     r6"
	".7:"
	"djnz    r7, .loop"
	// restore registers
	"ld   r5, #%2f"
	"ld   r6, #8"
	".pop:"
	"pop  @r5"
	"dec  r5"
	"djnz r6, .pop"
	"ret"
}

void printIntLf(bool number) {
}

void printIntLf(u8 number) {
}

void printIntLf(i16 number) {
	if (number < 0) {
		printChar('-');
		number = -number;
	}
	printUint(number);
	printChar(0x0d);
}

void setCursor(i16 x, i16 y) {
}

i16 getChar() {
	return 0;
}


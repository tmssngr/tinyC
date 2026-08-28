#ifdef X86_64
i32 __random__ = 0;
const __random__a = 48271;

void initRandom(i32 salt) {
	__random__ = salt;
}

i32 random() {
	i32 r = __random__;
	i32 b = (r & 0x7_ffff) * __random__a;
	i32 c = (r >> 15) * __random__a;
	i32 d = (c & 0xffff) << 15;
	i32 e = (c >> 16) + b + d;
	__random__ = (e & 0x7fff_ffff) + (e >> 31);
	return __random__;
}

i16 random16() {
	return (i16)random() & 0x7FFF;
}
#endif

#ifdef Z8
void initRandom(i32 salt) asm {
	"ld   %74, r0"
	"ld   %75, r1"
	"ld   %76, r2"
	"ld   %77, r3"
	"ld   r0, #%F7"
	"ld   r1, #%A8"
	"ld   r2, #%74"
	"ld   r3, #4"
".1:"
	"ldei @rr0, @r2"
	"djnz r3, .1"
	"ret"
}

i32 random() asm {
	"call %0836"
	"ld   r0, %74"
	"ld   r1, %75"
	"call %0836"
	"ld   r2, %74"
	"ld   r3, %75"
	"ret"
}

i16 random16() asm {
	"call %0836"
	"ld   r0, %74"
	"ld   r1, %75"
	"and  r0, #%7f"
	"ret"
}
#endif

u8 randomU8() {
	return (u8)random();
}

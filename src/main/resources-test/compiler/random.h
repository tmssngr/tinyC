i32 __random__ = 0;
const __random__a = 48271;

void initRandom(i32 salt) {
	__random__ = salt;
}

i32 random() {
	i32 r = __random__;
	i32 b = (r & 0x7ffff) * __random__a;
	i32 c = (r >> 15) * __random__a;
	i32 d = (c & 0xffff) << 15;
	i32 e = (c >> 16) + b + d;
	__random__ = (e & 0x7fffffff) + (e >> 31);
	return __random__;
}

u8 randomU8() {
	return (u8)random();
}

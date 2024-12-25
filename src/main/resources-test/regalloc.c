u8 simple() {
	u8 four = 4;
	u8 three = 3;
	u8 one = four - three;
	return one;
}

u8 registerHint(u8 a, u8 b) {
	return a + b;
}

u8 max(u8 a, u8 b) {
	if (a < b) {
		return b;
	}
	return a;
}

i16 fibonacci(u8 i) {
	i16 a = 0;
	i16 b = 1;
	while (i > 0) {
		i = i - 1;
		i16 c = a + b;
		a = b;
		b = c;
	}
	return a;
}

void main() {
	u8 one = simple();
	u8 two = 2;
	registerHint(one, two);
	u8 oneOrTwo = max(one, two);
	i16 f5 = fibonacci(5);
}

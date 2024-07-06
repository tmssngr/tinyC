void main() {
	i16 a = 10;  // a=var0
	print(a);
	i16* b = &a; // b=var1
	i16 c = *b - 1;  // c=var2
	print(c);
	i16* d = &c; // d=var3
	*d = *d - 1;
	print(c);
}
/*
u8* ptr(u8* ptr) {
	return ptr;
}
*/

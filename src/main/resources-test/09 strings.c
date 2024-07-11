u8* text = "hello world\n";

void main() {
	printString(text);
	u8* second = &text[1];
	printString(second);
	u8 chr = *text;
	print(chr);
}

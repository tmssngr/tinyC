void main() {
	u8 i = 5;
	while (i > 0) {
		print(i);
		i = i - 1;
	}

	while (true) {
		print(i);
		i = i + 1;
		if (i < 5) {
			continue;
		}
		break;
	}

	while (true) {
		return;
	}
}

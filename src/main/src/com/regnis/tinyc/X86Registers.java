package com.regnis.tinyc;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public abstract class X86Registers {

	protected abstract String getRegName(int reg, int size);

	public static final int TMP_REG = 99;

	public static final X86Registers WINDOWS = new X86Registers(0, 1, 2) {
		@Override
		protected String getRegName(int reg, int size) {
			return switch (reg) {
				case 0 -> xRegName('a', size); // return
				case 1 -> xRegName('c', size); // first arg
				case 2 -> xRegName('d', size); // second arg
				case 3 -> nRegName(8, size);   // third arg
				case 4 -> nRegName(9, size);   // fourth arg
				case 5 -> nRegName(10, size);
				// non-volatile
				case 6 -> xRegName('b', size);
				case 7 -> nRegName(12, size);
				case 8 -> nRegName(13, size);
				case 9 -> nRegName(14, size);
				case 10 -> nRegName(15, size);
				case TMP_REG -> nRegName(11, size); // temp
				default -> throw new IllegalStateException();
			};
		}
	};

	private final int rax;
	private final int rcx;
	private final int rdx;

	public X86Registers(int rax, int rcx, int rdx) {
		this.rax = rax;
		this.rcx = rcx;
		this.rdx = rdx;
	}

	public int rax() {
		return rax;
	}

	public int rcx() {
		return rcx;
	}

	public int rdx() {
		return rdx;
	}

	public String getRegName(int reg) {
		return getRegName(reg, 0);
	}

	@NotNull
	private static String nRegName(int reg, int size) {
		return switch (size) {
			case 1 -> "r" + reg + "b";
			case 2 -> "r" + reg + "w";
			case 4 -> "r" + reg + "d";
			default -> "r" + reg;
		};
	}

	@NotNull
	private static String xRegName(char chr, int size) {
		return switch (size) {
			case 1 -> chr + "l";
			case 2 -> chr + "x";
			case 4 -> "e" + chr + "x";
			default -> "r" + chr + "x";
		};
	}

	@NotNull
	private static String iRegName(char chr, int size) {
		return switch (size) {
			case 1 -> chr + "il";
			case 2 -> chr + "i";
			case 4 -> "e" + chr + "i";
			default -> "r" + chr + "i";
		};
	}
}

package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;

import java.io.*;
import java.util.*;

/**
 * @author Thomas Singer
 */
public abstract class Platform {

	public abstract Set<String> getDefines();

	public abstract Type getPointerIntType();

	public abstract int getMaxRegisters();

	public abstract AsmOut createAsmOut(BufferedWriter writer);

	public static final Platform X86Win64 = new Platform() {
		@Override
		public Set<String> getDefines() {
			return Set.of("X86_64");
		}

		@Override
		public Type getPointerIntType() {
			return Type.I64;
		}

		@Override
		public int getMaxRegisters() {
			return 4;
		}

		@Override
		public AsmOut createAsmOut(BufferedWriter writer) {
			return new X86Win64(writer);
		}
	};

	public static final Platform Z8 = new Platform() {
		@Override
		public Set<String> getDefines() {
			return Set.of("Z8");
		}

		@Override
		public Type getPointerIntType() {
			return Type.I16;
		}

		@Override
		public int getMaxRegisters() {
			return 4;
		}

		@Override
		public AsmOut createAsmOut(BufferedWriter writer) {
			return new Z8(writer);
		}
	};

	private Platform() {
	}
}

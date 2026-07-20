package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.linearscanregalloc.*;

import java.io.*;
import java.util.*;

/**
 * @author Thomas Singer
 */
public enum TargetArchitecture {

	WIN_X86_64(Set.of("X86_64", "__WINDOWS"),
	           new LSArchitecture.X86_64(4, 1, 2, X86Registers.WINDOWS)),

	LINUX_X86_64(Set.of("X86_64", "__LINUX"),
	             new LSArchitecture.X86_64(6, 1, 2, X86Registers.LINUX)),

	Z8(Set.of("Z8", "__Z8"),
	             new LSArchitecture.Z8());


	public final Set<String> defines;
	public final LSArchitecture architecture;

	TargetArchitecture(Set<String> defines, LSArchitecture architecture) {
		this.defines = defines;
		this.architecture = architecture;
	}

	AsmWriter createAsmWriter(BufferedWriter writer) {
		if (this == WIN_X86_64) {
			final LSArchitecture.X86_64 x86_64 = (LSArchitecture.X86_64)architecture;
			final int argCountInRegisters = x86_64.getArgCountInRegisters();
			final X86Registers registers = x86_64.getRegisters();
			return new X86_64_WindowsAsmWriter(writer, argCountInRegisters, registers);
		}
		if (this == LINUX_X86_64) {
			final LSArchitecture.X86_64 x86_64 = (LSArchitecture.X86_64)architecture;
			final int argCountInRegisters = x86_64.getArgCountInRegisters();
			final X86Registers registers = x86_64.getRegisters();
			return new X86_64_LinuxAsmWriter(writer, argCountInRegisters, registers);
		}
		if (this == Z8) {
			return new Z8AsmWriter(writer);
		}
		throw new IllegalStateException();
	}
}

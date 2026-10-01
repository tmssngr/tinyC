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
	           Type.I64,
	           new LSArchitecture.X86_64(4, 1, 2, X86Registers.WINDOWS)),

	LINUX_X86_64(Set.of("X86_64", "__LINUX"),
	             Type.I64,
	             new LSArchitecture.X86_64(6, 1, 2, X86Registers.LINUX));

	public final Type pointerIntType;
	public final Set<String> defines;
	public final LSArchitecture architecture;

	TargetArchitecture(Set<String> defines, Type pointerIntType, LSArchitecture architecture) {
		this.pointerIntType = pointerIntType;
		this.defines = defines;
		this.architecture = architecture;
	}

	AsmWriter createAsmWriter(BufferedWriter writer) {
		final LSArchitecture.X86_64 x86_64 = (LSArchitecture.X86_64)architecture;
		final int argCountInRegisters = x86_64.getArgCountInRegisters();
		final X86Registers registers = x86_64.getRegisters();
		if (this == WIN_X86_64) {
			return new X86_64_WindowsAsmWriter(writer, argCountInRegisters, registers);
		}
		else {
			return new X86_64_LinuxAsmWriter(writer, argCountInRegisters, registers);
		}
	}
}

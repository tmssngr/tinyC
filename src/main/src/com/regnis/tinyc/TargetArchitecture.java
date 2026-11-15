package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.linearscanregalloc.*;

import java.io.*;
import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public enum TargetArchitecture {

	WIN_X86_64(Set.of("X86_64", "__WINDOWS"),
	           new LSArchitecture.X86_64(4, 1, 2, X86Registers.WINDOWS), new X86CanonicalNameProvider()),

	LINUX_X86_64(Set.of("X86_64", "__LINUX"),
	             new LSArchitecture.X86_64(6, 1, 2, X86Registers.LINUX), new X86CanonicalNameProvider()),

	Z8(Set.of("Z8", "__Z8"),
	   new LSArchitecture.Z8(), new Z8CanonicalNameProvider());

	public final Set<String> defines;
	public final LSArchitecture architecture;
	public final TypeChecker.CanonicalNameProvider canonicalNameProvider;

	TargetArchitecture(Set<String> defines, LSArchitecture architecture, TypeChecker.CanonicalNameProvider canonicalNameProvider) {
		this.defines = defines;
		this.architecture = architecture;
		this.canonicalNameProvider = canonicalNameProvider;
	}

	@NotNull
	AsmWriter createAsmWriter(@NotNull BufferedWriter writer, @NotNull TypeChecker.CanonicalNameProvider canonicalNameProvider) {
		if (this == WIN_X86_64) {
			final LSArchitecture.X86_64 x86_64 = (LSArchitecture.X86_64)architecture;
			final int argCountInRegisters = x86_64.getArgCountInRegisters();
			final X86Registers registers = x86_64.getRegisters();
			return new X86_64_WindowsAsmWriter(writer, argCountInRegisters, registers, canonicalNameProvider);
		}
		if (this == LINUX_X86_64) {
			final LSArchitecture.X86_64 x86_64 = (LSArchitecture.X86_64)architecture;
			final int argCountInRegisters = x86_64.getArgCountInRegisters();
			final X86Registers registers = x86_64.getRegisters();
			return new X86_64_LinuxAsmWriter(writer, argCountInRegisters, registers, canonicalNameProvider);
		}
		if (this == Z8) {
			return new Z8AsmWriter(writer, architecture.getCallingConventionProvider(), canonicalNameProvider);
		}
		throw new IllegalStateException();
	}
}

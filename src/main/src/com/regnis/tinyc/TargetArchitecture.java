package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.linearscanregalloc.*;

import java.io.*;
import java.util.*;

/**
 * @author Thomas Singer
 */
public enum TargetArchitecture {

	WIN_X86_64(Set.of("X86_64"),
	           Type.I64,
	           LSArchitecture.WIN_X86_64),
	Z8(Set.of("Z8"),
	   Type.I16,
	   LSArchitecture.Z8);

	public final Type pointerIntType;
	public final Set<String> defines;
	public final LSArchitecture architecture;

	TargetArchitecture(Set<String> defines, Type pointerIntType, LSArchitecture architecture) {
		this.pointerIntType = pointerIntType;
		this.defines = defines;
		this.architecture = architecture;
	}

	AsmWriter createAsmWriter(BufferedWriter writer) {
		return new X86Win64(writer);
	}
}

package com.regnis.tinyc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class X86StackOffsetsTest {

	@Test
	public void testNoVars() {
		windowsLinux(List.of(), List.of(), 4, 0,
		             (X86StackOffsets offsets) -> {
			             assertEquals(8, offsets.getRspOffset());
		             });

		windowsLinux(List.of(), List.of(), 4, 1,
		             (X86StackOffsets offsets) -> {
			             assertEquals(0, offsets.getRspOffset());
			             assertEquals(0, offsets.getCallArgSpace());
		             });
	}

	@Test
	public void testLocalVars() {
		final IRVar a = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar b = new IRVar("b", 1, VariableScope.function, Type.I16);

		windowsLinux(List.of(
				             new IRVarDef(a, 2)
		             ), List.of(), 4, 0,
		             (X86StackOffsets offsets) -> {
			             assertEquals(8, offsets.getRspOffset());
			             assertEquals(0, offsets.getCallArgSpace());
			             assertEquals(0, offsets.getOffset(a));
		             });

		// 2 vars
		windowsLinux(List.of(
				             new IRVarDef(a, 2),
				             new IRVarDef(b, 2)
		             ), List.of(), 4, 0,
		             (X86StackOffsets offsets) -> {
			             assertEquals(8, offsets.getRspOffset());
			             assertEquals(0, offsets.getCallArgSpace());
			             assertEquals(0, offsets.getOffset(a));
			             assertEquals(2, offsets.getOffset(b));
		             });
	}

	@Test
	public void testArgs() {
		final IRVar arg1 = new IRVar("a1", 0, VariableScope.parameter, Type.I16);
		final IRVar arg2 = new IRVar("a2", 1, VariableScope.parameter, Type.I16);
		final IRVar arg3 = new IRVar("a3", 2, VariableScope.parameter, Type.I16);
		final IRVar arg4 = new IRVar("a4", 3, VariableScope.parameter, Type.I16);
		final IRVar arg5 = new IRVar("a5", 4, VariableScope.parameter, Type.I16);
		final IRVar arg6 = new IRVar("a6", 5, VariableScope.parameter, Type.I16);
		final IRVar arg7 = new IRVar("a7", 6, VariableScope.parameter, Type.I16);
		final IRVar arg8 = new IRVar("a8", 7, VariableScope.parameter, Type.I16);
		final IRVar var1 = new IRVar("v1", 8, VariableScope.function, Type.I16);
		final IRVar var2 = new IRVar("v2", 9, VariableScope.function, Type.I16);

		windowsLinux(List.of(
				             new IRVarDef(arg1, 2)
		             ), List.of(), 4, 0,
		             offsets -> {
			             assertEquals(8, offsets.getRspOffset());
			             assertEquals(0, offsets.getCallArgSpace());
			             assertEquals(16, offsets.getOffset(arg1));
		             },
		             offsets -> {
			             assertEquals(8, offsets.getRspOffset());
			             assertEquals(0, offsets.getCallArgSpace());
			             assertEquals(0, offsets.getOffset(arg1));
		             });

		// 2 args
		windowsLinux(List.of(
				             new IRVarDef(arg1, 2),
				             new IRVarDef(arg2, 2)
		             ), List.of(), 4, 0,
		             (X86StackOffsets offsets) -> {
			             assertEquals(8, offsets.getRspOffset());
			             assertEquals(0, offsets.getCallArgSpace());
			             assertEquals(16, offsets.getOffset(arg1));
			             assertEquals(24, offsets.getOffset(arg2));
		             },
		             (X86StackOffsets offsets) -> {
			             assertEquals(8, offsets.getRspOffset());
			             assertEquals(0, offsets.getCallArgSpace());
			             assertEquals(0, offsets.getOffset(arg1));
			             assertEquals(2, offsets.getOffset(arg2));
		             });

		// 8 args linux
		//  8h arg8
		//  8h arg7
		// -- aligned to 10h
		//  8h return address
		//  8h free space for alignment
		//  0h local vars, including arg1..arg6 not stored in registers
		//  0h pushed clobbered non-volatile regs
		// -- aligned to 10h
		final X86StackOffsets linux = X86StackOffsets.createLinuxInstance(List.of(
				new IRVarDef(arg1, 2),
				new IRVarDef(arg2, 2),
				new IRVarDef(arg3, 2),
				new IRVarDef(arg4, 2),
				new IRVarDef(arg5, 2),
				new IRVarDef(arg6, 2),
				new IRVarDef(arg7, 2),
				new IRVarDef(arg8, 2),
				new IRVarDef(var1, 2),
				new IRVarDef(var2, 2)
		), List.of(), 6, 0);
		assertEquals(24, linux.getRspOffset());
		assertEquals(0, linux.getCallArgSpace());
		assertEquals(0, linux.getOffset(arg1));
		assertEquals(2, linux.getOffset(arg2));
		assertEquals(4, linux.getOffset(arg3));
		assertEquals(6, linux.getOffset(arg4));
		assertEquals(8, linux.getOffset(arg5));
		assertEquals(10, linux.getOffset(arg6));
		assertEquals(32, linux.getOffset(arg7));
		assertEquals(40, linux.getOffset(arg8));
		assertEquals(12, linux.getOffset(var1));
		assertEquals(14, linux.getOffset(var2));
	}

	@Test
	public void testCallArgs() {
		windowsLinux(List.of(), List.of(
				             List.of()
		             ), 4, 0,
		             (X86StackOffsets offsets) -> {
			             // Windows:
			             // -- aligned to 10h
			             //  8h return address
			             //  8h free space for alignment
			             //  0h local vars
			             //  0h pushed clobbered non-volatile regs
			             // 20h shadow space
			             // -- aligned to 10h
			             assertEquals(8, offsets.getRspOffset());
			             assertEquals(0x20, offsets.getCallArgSpace());
		             },
		             (X86StackOffsets offsets) -> {
			             // Linux:
			             // -- aligned to 10h
			             //  8h return address
			             //  8h free space for alignment
			             //  0h local vars
			             //  0h pushed clobbered non-volatile regs
			             //     no shadow space
			             // -- aligned to 10h
			             assertEquals(8, offsets.getRspOffset());
			             assertEquals(0, offsets.getCallArgSpace());
		             });

		windowsLinux(List.of(), List.of(
				             List.of(
						             new IRVar("a", 0, VariableScope.register, Type.U8)
				             )
		             ), 4, 0,
		             (X86StackOffsets offsets) -> {
			             // Windows:
			             // -- aligned to 10h
			             //  8h return address
			             //  8h free space for alignment
			             //  0h local vars
			             //  0h pushed clobbered non-volatile regs
			             // 20h shadow space
			             // -- aligned to 10h
			             assertEquals(8, offsets.getRspOffset());
			             assertEquals(0x20, offsets.getCallArgSpace());
		             },
		             (X86StackOffsets offsets) -> {
			             // Linux:
			             // -- aligned to 10h
			             //  8h return address
			             //  8h free space for alignment
			             //  0h local vars
			             //  0h pushed clobbered non-volatile regs
			             //     no shadow space, argument is passed in register
			             // -- aligned to 10h
			             assertEquals(8, offsets.getRspOffset());
			             assertEquals(0, offsets.getCallArgSpace());
		             });

		final IRVar call1Arg1 = new IRVar("c1a1", 0, VariableScope.function, Type.U8);
		windowsLinux(List.of(
				             new IRVarDef(call1Arg1, 1)
		             ), List.of(
				             List.of(
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             call1Arg1
				             )
		             ), 4, 0,
		             (X86StackOffsets offsets) -> {
			             // Windows:
			             // -- aligned to 10h
			             //  8h return address
			             //  0h free space for alignment
			             //  0h local vars
			             //  0h pushed clobbered non-volatile regs
			             // 28h space for call arguments
			             // -- aligned to 10h
			             assertEquals(0, offsets.getRspOffset());
			             assertEquals(0x28, offsets.getCallArgSpace());
			             assertEquals(0x20, offsets.getOffset(call1Arg1));
		             },
		             (X86StackOffsets offsets) -> {
			             // Linux:
			             // -- aligned to 10h
			             //  8h return address
			             //  0h free space for alignment
			             //  0h local vars
			             //  0h pushed clobbered non-volatile regs
			             //  8h space for 5th call argument passed on stack
			             // -- aligned to 10h
			             assertEquals(0, offsets.getRspOffset());
			             assertEquals(8, offsets.getCallArgSpace());
			             assertEquals(0, offsets.getOffset(call1Arg1));
		             });

		final IRVar varC = new IRVar("c", 1, VariableScope.function, Type.I16);
		windowsLinux(List.of(
				             new IRVarDef(call1Arg1, 1),
				             new IRVarDef(varC, 2)
		             ), List.of(
				             List.of(
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             call1Arg1
				             )
		             ), 4, 0,
		             (X86StackOffsets offsets) -> {
			             // Windows:
			             // -- aligned to 10h
			             //  8h return address
			             //  0h free space for alignment
			             //  0h local vars
			             //  0h pushed clobbered non-volatile regs
			             // 28h space for call arguments
			             // -- aligned to 10h
			             assertEquals(16, offsets.getRspOffset());
			             assertEquals(0x28, offsets.getCallArgSpace());
			             assertEquals(0x20, offsets.getOffset(call1Arg1));
			             assertEquals(0x28, offsets.getOffset(varC));
		             },
		             (X86StackOffsets offsets) -> {
			             // Linux:
			             // -- aligned to 10h
			             //  8h return address                                     _
			             // 14h free space for alignment                            |_ rspOffset
			             //  2h varC                                               _|
			             //  0h pushed clobbered non-volatile regs
			             //  8h callArgSpace (call1Arg1)
			             // -- aligned to 10h
			             assertEquals(0x10, offsets.getRspOffset());
			             assertEquals(8, offsets.getCallArgSpace());
			             assertEquals(0, offsets.getOffset(call1Arg1));
			             assertEquals(8, offsets.getOffset(varC));
		             });
	}

	private void windowsLinux(@NotNull List<IRVarDef> localVars, @NotNull List<List<IRVar>> callsArgs, int argCountInRegisters, int pushedNonvolatileRegisterCount,
	                          Consumer<X86StackOffsets> consumer) {
		windowsLinux(localVars, callsArgs, argCountInRegisters, pushedNonvolatileRegisterCount,
		             consumer, consumer);
	}

	private void windowsLinux(@NotNull List<IRVarDef> localVars, @NotNull List<List<IRVar>> callsArgs, int argCountInRegisters, int pushedNonvolatileRegisterCount,
	                          Consumer<X86StackOffsets> windowsConsumer, Consumer<X86StackOffsets> linuxConsumer) {
		X86StackOffsets offsets = X86StackOffsets.createWindowsInstance(localVars, callsArgs, argCountInRegisters, pushedNonvolatileRegisterCount);
		windowsConsumer.accept(offsets);

		offsets = X86StackOffsets.createLinuxInstance(localVars, callsArgs, argCountInRegisters, pushedNonvolatileRegisterCount);
		linuxConsumer.accept(offsets);
	}
}
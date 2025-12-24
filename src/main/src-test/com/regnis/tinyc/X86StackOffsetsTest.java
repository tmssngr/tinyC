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
		final IRVar a = new IRVar("a", 0, VariableScope.argument, Type.I16);
		final IRVar b = new IRVar("b", 1, VariableScope.argument, Type.I16);

		windowsLinux(List.of(
				             new IRVarDef(a, 2)
		             ), List.of(), 4, 0,
		             offsets -> {
			             assertEquals(8, offsets.getRspOffset());
			             assertEquals(0, offsets.getCallArgSpace());
			             assertEquals(16, offsets.getOffset(a));
		             });

		// 2 vars
		windowsLinux(List.of(
				             new IRVarDef(a, 2),
				             new IRVarDef(b, 2)
		             ), List.of(), 4, 0,
		             (X86StackOffsets offsets) -> {
			             assertEquals(8, offsets.getRspOffset());
			             assertEquals(0, offsets.getCallArgSpace());
			             assertEquals(16, offsets.getOffset(a));
			             assertEquals(24, offsets.getOffset(b));
		             });
	}

	@Test
	public void testCallArgs() {
		// -- aligned to 10h
		//  8h return address
		//  8h free space for alignment
		//  0h local vars
		//  0h pushed clobbered non-volatile regs
		// 20h space for call arguments
		// -- aligned to 10h
		windowsLinux(List.of(), List.of(
				             List.of(
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8)
				             )
		             ), 4, 0,
		             (X86StackOffsets offsets) -> {
			             assertEquals(8, offsets.getRspOffset());
			             assertEquals(0x20, offsets.getCallArgSpace());
		             });

		final IRVar varB = new IRVar("b", 0, VariableScope.function, Type.U8);
		windowsLinux(List.of(
				             new IRVarDef(varB, 1)
		             ), List.of(
				             List.of(
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             varB
				             )
		             ), 4, 0,
		             (X86StackOffsets offsets) -> {
			             // -- aligned to 10h
			             //  8h return address
			             //  0h free space for alignment
			             //  0h local vars
			             //  0h pushed clobbered non-volatile regs
			             // 28h space for call arguments
			             // -- aligned to 10h
			             assertEquals(0, offsets.getRspOffset());
			             assertEquals(0x28, offsets.getCallArgSpace());
			             assertEquals(0x20, offsets.getOffset(varB));
		             },
		             (X86StackOffsets offsets) -> {
			             // -- aligned to 10h
			             //  8h return address
			             //  0h free space for alignment
			             //  0h local vars
			             //  0h pushed clobbered non-volatile regs
			             // 28h space for call arguments
			             // -- aligned to 10h
			             assertEquals(0, offsets.getRspOffset());
			             assertEquals(0x28, offsets.getCallArgSpace());
			             assertEquals(0x20, offsets.getOffset(varB));
		             });

		final IRVar varC = new IRVar("c", 1, VariableScope.function, Type.I16);
		// -- aligned to 10h
		//  8h return address
		//  8h free space for alignment
		//  8h local vars
		//  0h pushed clobbered non-volatile regs
		// 28h space for call arguments
		// -- aligned to 10h
		windowsLinux(List.of(
				             new IRVarDef(varB, 1),
				             new IRVarDef(varC, 2)
		             ), List.of(
				             List.of(
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             new IRVar("a", 0, VariableScope.register, Type.U8),
						             varB
				             )
		             ), 4, 0,
		             (X86StackOffsets offsets) -> {
			             assertEquals(16, offsets.getRspOffset());
			             assertEquals(0x28, offsets.getCallArgSpace());
			             assertEquals(0x20, offsets.getOffset(varB));
			             assertEquals(0x28, offsets.getOffset(varC));
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
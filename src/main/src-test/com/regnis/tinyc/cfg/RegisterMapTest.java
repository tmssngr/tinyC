package com.regnis.tinyc.cfg;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.jetbrains.annotations.*;
import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class RegisterMapTest {

	@Test
	public void testBasic() {
		final IRVar t0 = tmp(0, Type.I64);
		final IRVar t1 = tmp(1, Type.I64);
		final IRVar t2 = tmp(2, Type.I16);
		final IRVar t3 = tmp(3, Type.I64);
		final IRVar t4 = tmp(4, Type.I64);
		final IRVar t4b = tmp(4, Type.I16);
		final RegisterMap map = new RegisterMap(4);
		assertEquals(reg(0, t3), map.useRegisterForWriting(t3));
		assertEquals(reg(0, t3), map.getRegisterVar(t3));
		assertNull(map.getRegisterVar(t2));
		assertEquals(reg(1, t2), map.useRegisterForWriting(t2));
		assertEquals(reg(2, t1), map.useRegisterForWriting(t1));
		assertEquals(reg(3, t0), map.useRegisterForWriting(t0));

		try {
			map.useRegisterForReading(t1);
			fail();
		}
		catch (IllegalStateException ignored) {
		}

		try {
			map.useRegisterForReading(t4);
			fail();
		}
		catch (IllegalStateException ignored) {
		}

		assertNull(map.maybeFreeRegister(t4));
		assertEquals(reg(1, t2), map.maybeFreeRegister(t2));
		assertEquals(reg(1, t4b), map.useRegisterForReading(t4b));
	}

	@Test
	public void testNoSpill() {
		final IRVar tmp0 = tmp(0, Type.I64);
		final IRVar tmp1 = tmp(1, Type.I64);
		final IRVar tmp2 = tmp(2, Type.I16);
		final IRVar tmp3 = tmp(3, Type.I64);
		final IRVar tmp4 = tmp(4, Type.I32);
		final RegisterMap map = new RegisterMap(4);
		assertEquals(reg(0, tmp3), map.useRegisterForWriting(tmp3));
		assertEquals(reg(1, tmp2), map.useRegisterForWriting(tmp2));
		assertEquals(reg(2, tmp1), map.useRegisterForWriting(tmp1));
		assertEquals(reg(3, tmp0), map.useRegisterForWriting(tmp0));
		assertEquals(List.of(tmp3,
		                     tmp2,
		                     tmp1,
		                     tmp0), map.createDebugState());
		map.maybeSpillRegisters(Set.of(tmp3, tmp2, tmp1, tmp0),
		                        Set.of(tmp1),
		                        Set.of(tmp1, tmp2),
		                        Set.of(tmp4),
		                        (var, regVar) -> fail());
		assertEquals(List.of(tmp3,
		                     tmp2,
		                     tmp1,
		                     tmp0), map.createDebugState());
	}

	@Test
	public void testSpill1() {
		final IRVar tmp0 = tmp(0, Type.I64);
		final IRVar tmp1 = tmp(1, Type.I64);
		final IRVar tmp2 = tmp(2, Type.I16);
		final IRVar tmp3 = tmp(3, Type.I64);
		final IRVar tmp4 = tmp(4, Type.I32);
		final RegisterMap map = new RegisterMap(4);
		assertEquals(reg(0, tmp3), map.useRegisterForWriting(tmp3));
		assertEquals(reg(1, tmp2), map.useRegisterForWriting(tmp2));
		assertEquals(reg(2, tmp1), map.useRegisterForWriting(tmp1));
		assertEquals(reg(3, tmp0), map.useRegisterForReading(tmp0));
		assertEquals(List.of(tmp3,
		                     tmp2,
		                     tmp1,
		                     tmp0), map.createDebugState());
		map.maybeSpillRegisters(Set.of(tmp3, tmp2, tmp1, tmp0),
		                        Set.of(),
		                        Set.of(tmp1, tmp2),
		                        Set.of(tmp4),
		                        // not spilled because reg 3 was not written
		                        (var, regVar) -> fail());
		assertEquals(Arrays.asList(tmp3,
		                           tmp2,
		                           tmp1,
		                           null), map.createDebugState());
	}

	@Test
	public void testSpill2() {
		final IRVar tmp0 = tmp(0, Type.I64);
		final IRVar tmp1 = tmp(1, Type.I64);
		final IRVar tmp2 = tmp(2, Type.I16);
		final IRVar tmp3 = tmp(3, Type.I64);
		final IRVar tmp4 = tmp(4, Type.I32);
		final RegisterMap map = new RegisterMap(4);
		assertEquals(reg(0, tmp3), map.useRegisterForWriting(tmp3));
		assertEquals(reg(1, tmp2), map.useRegisterForWriting(tmp2));
		assertEquals(reg(2, tmp1), map.useRegisterForWriting(tmp1));
		assertEquals(reg(3, tmp0), map.useRegisterForWriting(tmp0));
		assertEquals(List.of(tmp3,
		                     tmp2,
		                     tmp1,
		                     tmp0), map.createDebugState());
		map.maybeSpillRegisters(Set.of(tmp3, tmp2, tmp1, tmp0),
		                        Set.of(),
		                        Set.of(tmp1, tmp2),
		                        Set.of(tmp4),
		                        (var, regVar) -> {
			                        assertEquals(tmp3, var);
			                        assertEquals(reg(0, tmp3), regVar);
		                        });
		assertEquals(Arrays.asList(null,
		                           tmp2,
		                           tmp1,
		                           tmp0), map.createDebugState());
	}

	@Test
	public void testSpill3() {
		final IRVar tmp0 = tmp(0, Type.I64);
		final IRVar tmp1 = tmp(1, Type.I64);
		final IRVar tmp2 = tmp(2, Type.I16);
		final IRVar tmp3 = tmp(3, Type.I64);
		final IRVar tmp4 = tmp(4, Type.I32);
		final RegisterMap map = new RegisterMap(4);
		assertEquals(reg(0, tmp3), map.useRegisterForWriting(tmp3));
		assertEquals(reg(1, tmp2), map.useRegisterForWriting(tmp2));
		assertEquals(reg(2, tmp1), map.useRegisterForWriting(tmp1));
		assertEquals(reg(3, tmp0), map.useRegisterForWriting(tmp0));
		assertEquals(List.of(tmp3,
		                     tmp2,
		                     tmp1,
		                     tmp0), map.createDebugState());
		final Set<Pair<IRVar, IRVar>> spilled = new HashSet<>();
		map.maybeSpillRegisters(Set.of(tmp3, tmp2, tmp1, tmp0, tmp4),
		                        Set.of(),
		                        Set.of(tmp2, tmp4),
		                        Set.of(tmp4),
		                        (var, regVar) -> assertTrue(spilled.add(new Pair<>(var, regVar))));
		assertEquals(Set.of(new Pair<>(tmp3, reg(0, tmp3)),
		                    new Pair<>(tmp1, reg(2, tmp1))), spilled);
		assertEquals(Arrays.asList(null,
		                           tmp2,
		                           null,
		                           tmp0), map.createDebugState());
	}

	@NotNull
	private static IRVar reg(int index, Type type) {
		return new IRVar("r." + index, index, VariableScope.register, type, true);
	}

	@NotNull
	private static IRVar reg(int index, @NotNull IRVar var) {
		return IRVar.createRegisterVar(index, var);
	}

	@NotNull
	private static IRVar tmp(int index, Type type) {
		return new IRVar("t." + index, index, VariableScope.function, type, true);
	}
}
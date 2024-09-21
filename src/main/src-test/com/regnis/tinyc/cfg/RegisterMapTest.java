package com.regnis.tinyc.cfg;

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
		final RegisterMap map = new RegisterMap(4);
		assertEquals(reg(0, Type.I64), map.useRegisterForWriting(tmp(3, Type.I64)));
		assertEquals(reg(0, Type.I64), map.getRegisterVar(tmp(3, Type.I64)));
		assertNull(map.getRegisterVar(tmp(2, Type.I16)));
		assertEquals(reg(1, Type.I16), map.useRegisterForWriting(tmp(2, Type.I16)));
		assertEquals(reg(2, Type.I64), map.useRegisterForWriting(tmp(1, Type.I64)));
		assertEquals(reg(3, Type.I64), map.useRegisterForWriting(tmp(0, Type.I64)));

		try {
			map.useRegisterForReading(tmp(1, Type.I64));
			fail();
		}
		catch (IllegalStateException ignored) {
		}

		try {
			map.useRegisterForReading(tmp(4, Type.I64));
			fail();
		}
		catch (IllegalStateException ignored) {
		}

		assertNull(map.maybeFreeRegister(tmp(4, Type.I64)));
		assertEquals(reg(1, Type.I16), map.maybeFreeRegister(tmp(2, Type.I16)));
		assertEquals(reg(1, Type.I16), map.useRegisterForReading(tmp(4, Type.I16)));
	}

	@Test
	public void testNoSpill() {
		final RegisterMap map = new RegisterMap(4);
		assertEquals(reg(0, Type.I64), map.useRegisterForWriting(tmp(3, Type.I64)));
		assertEquals(reg(1, Type.I16), map.useRegisterForWriting(tmp(2, Type.I16)));
		assertEquals(reg(2, Type.I64), map.useRegisterForWriting(tmp(1, Type.I64)));
		assertEquals(reg(3, Type.I64), map.useRegisterForWriting(tmp(0, Type.I64)));
		assertEquals(List.of(tmp(3, Type.I64),
		                     tmp(2, Type.I16),
		                     tmp(1, Type.I64),
		                     tmp(0, Type.I64)), map.createDebugState());
		map.maybeSpillRegisters(Set.of(tmp(3), tmp(2), tmp(1), tmp(0)),
		                        Set.of(tmp(1)),
		                        Set.of(tmp(1), tmp(2)),
		                        Set.of(tmp(4)),
		                        (var, regVar) -> fail());
		assertEquals(List.of(tmp(3, Type.I64),
		                     tmp(2, Type.I16),
		                     tmp(1, Type.I64),
		                     tmp(0, Type.I64)), map.createDebugState());
	}

	@Test
	public void testSpill1() {
		final RegisterMap map = new RegisterMap(4);
		assertEquals(reg(0, Type.I64), map.useRegisterForWriting(tmp(3, Type.I64)));
		assertEquals(reg(1, Type.I16), map.useRegisterForWriting(tmp(2, Type.I16)));
		assertEquals(reg(2, Type.I64), map.useRegisterForWriting(tmp(1, Type.I64)));
		assertEquals(reg(3, Type.I64), map.useRegisterForReading(tmp(0, Type.I64)));
		assertEquals(List.of(tmp(3, Type.I64),
		                     tmp(2, Type.I16),
		                     tmp(1, Type.I64),
		                     tmp(0, Type.I64)), map.createDebugState());
		map.maybeSpillRegisters(Set.of(tmp(3), tmp(2), tmp(1), tmp(0)),
		                        Set.of(),
		                        Set.of(tmp(1), tmp(2)),
		                        Set.of(tmp(4)),
								// not spilled because reg 3 was not written
		                        (var, regVar) -> fail());
		assertEquals(Arrays.asList(tmp(3, Type.I64),
		                           tmp(2, Type.I16),
		                           tmp(1, Type.I64),
		                           null), map.createDebugState());
	}

	@Test
	public void testSpill2() {
		final RegisterMap map = new RegisterMap(4);
		assertEquals(reg(0, Type.I64), map.useRegisterForWriting(tmp(3, Type.I64)));
		assertEquals(reg(1, Type.I16), map.useRegisterForWriting(tmp(2, Type.I16)));
		assertEquals(reg(2, Type.I64), map.useRegisterForWriting(tmp(1, Type.I64)));
		assertEquals(reg(3, Type.I64), map.useRegisterForWriting(tmp(0, Type.I64)));
		assertEquals(List.of(tmp(3, Type.I64),
		                     tmp(2, Type.I16),
		                     tmp(1, Type.I64),
		                     tmp(0, Type.I64)), map.createDebugState());
		map.maybeSpillRegisters(Set.of(tmp(3), tmp(2), tmp(1), tmp(0)),
		                        Set.of(),
		                        Set.of(tmp(1), tmp(2)),
		                        Set.of(tmp(4)),
		                        (var, regVar) -> {
			                        assertEquals(tmp(3, Type.I64), var);
			                        assertEquals(reg(0, Type.I64), regVar);
		                        });
		assertEquals(Arrays.asList(null,
		                           tmp(2, Type.I16),
		                           tmp(1, Type.I64),
		                           tmp(0, Type.I64)), map.createDebugState());
	}

	@Test
	public void testSpill3() {
		final RegisterMap map = new RegisterMap(4);
		assertEquals(reg(0, Type.I64), map.useRegisterForWriting(tmp(3, Type.I64)));
		assertEquals(reg(1, Type.I16), map.useRegisterForWriting(tmp(2, Type.I16)));
		assertEquals(reg(2, Type.I64), map.useRegisterForWriting(tmp(1, Type.I64)));
		assertEquals(reg(3, Type.I64), map.useRegisterForWriting(tmp(0, Type.I64)));
		assertEquals(List.of(tmp(3, Type.I64),
		                     tmp(2, Type.I16),
		                     tmp(1, Type.I64),
		                     tmp(0, Type.I64)), map.createDebugState());
		final Set<Pair<IRVar, IRVar>> spilled = new HashSet<>();
		map.maybeSpillRegisters(Set.of(tmp(3), tmp(2), tmp(1), tmp(0), tmp(4)),
		                        Set.of(),
		                        Set.of(tmp(2), tmp(4)),
		                        Set.of(tmp(4)),
		                        (var, regVar) -> assertTrue(spilled.add(new Pair<>(var, regVar))));
		assertEquals(Set.of(new Pair<>(tmp(3, Type.I64), reg(0, Type.I64)),
		                    new Pair<>(tmp(1, Type.I64), reg(2, Type.I64))), spilled);
		assertEquals(Arrays.asList(null,
		                           tmp(2, Type.I16),
		                           null,
		                           tmp(0, Type.I64)), map.createDebugState());
	}

	@NotNull
	private static IRVar reg(int index, Type type) {
		return new IRVar("r." + index, index, VariableScope.register, type, true);
	}

	@NotNull
	private static IRVar tmp(int index, Type type) {
		return new IRVar("t." + index, index, VariableScope.function, type, true);
	}

	@NotNull
	private static LiveVar tmp(int index) {
		return new LiveVar(VariableScope.function, index, "t." + index);
	}

	public record Pair<A, B>(A a, B b) {
	}
}
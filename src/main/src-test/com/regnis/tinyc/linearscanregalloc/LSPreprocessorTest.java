package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;
import java.util.function.Function;

import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class LSPreprocessorTest {

	@Test
	public void testArgs() {
		final IRVar a = new IRVar("a", 0, VariableScope.argument, Type.I16);
		final IRVar b = new IRVar("b", 1, VariableScope.argument, Type.I16);
		final IRVar c = new IRVar("c", 2, VariableScope.argument, Type.I16);
		final IRVar d = new IRVar("d", 3, VariableScope.function, Type.I16);
		final var result = LSPreprocessor.process(new IRFunction("name", "label", Type.BOOL,
		                                                         new IRVarInfos(List.of(
				                                                         new IRVarDef(a, 2),
				                                                         new IRVarDef(b, 2),
				                                                         new IRVarDef(c, 2),
				                                                         new IRVarDef(d, 2)
		                                                         ), Set.of(), null),
		                                                         List.of(
				                                                         new IRBinary(d, IRBinary.Op.Add, a, b, Location.DUMMY),
				                                                         new IRCall(c, "sub", List.of(d, c, b, a), Location.DUMMY),
				                                                         new IRRetValue(c, Location.DUMMY)
		                                                         )),
		                                          new LSArchitecture(2, 1, 0, false));
		assertEquals(List.of(
				new IRMove(a, a.asRegister(1), Location.DUMMY),
				new IRMove(b, b.asRegister(2), Location.DUMMY),
				new IRBinary(d, IRBinary.Op.Add, a, b, Location.DUMMY),
				new IRMove(d.asRegister(1), d, Location.DUMMY),
				new IRMove(c.asRegister(2), c, Location.DUMMY),
				new IRCall(c.asRegister(0), "sub",
				           List.of(
						           d.asRegister(1),
						           c.asRegister(2),
						           b,
						           a
				           ), Location.DUMMY),
				new IRMove(c, c.asRegister(0), Location.DUMMY),
				new IRMove(c.asRegister(0), c, Location.DUMMY)
		), result.first().instructions());
	}

	@Test
	public void testAddressedGlobal() {
		final IRVar varA = new IRVar("a", 0, VariableScope.global, Type.I16);
		final IRVar varB = new IRVar("b", 0, VariableScope.function, Type.I16);
		final IRVar varAddrA = new IRVar("addrA", 1, VariableScope.function, Type.pointer(Type.I16));
		final IRVar varTempA = new IRVar(LSPreprocessorCachedVarLayer.PREFIX + "a", 2, VariableScope.function, Type.I16);

		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varA, 2)
		), Set.of(varA), null);
		final IRVarInfos localVarInfos = new IRVarInfos(List.of(
				new IRVarDef(varB, 2),
				new IRVarDef(varAddrA, 8)
		), Set.of(), globalVarInfos);

		final var result = LSPreprocessor.process(new IRFunction("name", "label", Type.VOID, localVarInfos,
		                                                         List.of(
				                                                         new IRLiteral(varA, 1, Location.DUMMY),
				                                                         new IRAddrOf(varAddrA, varA, Location.DUMMY),
				                                                         new IRLiteral(varA, 2, Location.DUMMY),
				                                                         new IRLiteral(varB, 3, Location.DUMMY),
				                                                         new IRMemStore(varAddrA, varB, Location.DUMMY),
				                                                         new IRLiteral(varA, 4, Location.DUMMY),
				                                                         new IRJump("label")
		                                                         )), new LSArchitecture(2, 0, 0, false));
		final IRFunction function = result.first();
		final Function<IRVar, IRVar> originalVarMapping = result.second();
		IRTestUtils.assertEqualsInstructions(List.of(
				new IRLiteral(varTempA, 1, Location.DUMMY),
				new IRAddrOf(varAddrA, varA, Location.DUMMY),
				new IRLiteral(varTempA, 2, Location.DUMMY),
				new IRLiteral(varB, 3, Location.DUMMY),
				new IRMove(varA, varTempA, Location.DUMMY),
				new IRMemStore(varAddrA, varB, Location.DUMMY),
				new IRLiteral(varTempA, 4, Location.DUMMY),
				new IRMove(varA, varTempA, Location.DUMMY),
				new IRJump("label")
		), function.instructions());
		assertEquals(List.of(
				             new IRVarDef(varB, 2),
				             new IRVarDef(varAddrA, 8),
				             new IRVarDef(varTempA, 2)
		             ),
		             function.varInfos().vars());
		assertEquals(varA, originalVarMapping.apply(varTempA));
	}
}
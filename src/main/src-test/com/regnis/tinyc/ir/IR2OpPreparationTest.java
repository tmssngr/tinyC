package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;
import com.regnis.tinyc.ast.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class IR2OpPreparationTest {

	@Test
	public void test() {
		final IRVarInfos globalVarInfo = new IRVarInfos(List.of(), Set.of(), null);
		final IRVar varA = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar varB = new IRVar("b", 1, VariableScope.function, Type.I16);
		final IRVar varC = new IRVar("c", 2, VariableScope.function, Type.I16);
		final IRVar varTmp1 = new IRVar(IR2OpPreparation.TMP_PREFIX + 1, 3, VariableScope.function, Type.I16);
		final IRVarInfos varInfos = new IRVarInfos(List.of(
				new IRVarDef(varA, 2),
				new IRVarDef(varB, 2),
				new IRVarDef(varC, 2)
		), Set.of(), globalVarInfo);
		final Pair<List<IRInstruction>, IRVarInfos> result = IR2OpPreparation.convertTo2Op(List.of(
				new IRBinary(varA, IRBinary.Op.Add, varA, varC),
				new IRBinary(varA, IRBinary.Op.Add, varA, varA),
				new IRBinary(varA, IRBinary.Op.Add, varB, varC),
				new IRBinary(varA, IRBinary.Op.Add, varB, varA),

				new IRBinary(varA, IRBinary.Op.Add, varA, 1),
				new IRBinary(varA, IRBinary.Op.Add, varB, 1),

				new IRBinary(varA, IRBinary.Op.Sub, varA, varC),
				new IRBinary(varA, IRBinary.Op.Sub, varA, varA),
				new IRBinary(varA, IRBinary.Op.Sub, varB, varC),
				new IRBinary(varA, IRBinary.Op.Sub, varB, varA),

				new IRBinary(varA, IRBinary.Op.Sub, varA, 1),
				new IRBinary(varA, IRBinary.Op.Sub, varB, 1)
		), varInfos, Type.I64);

		final Iterator<IRInstruction> i = result.first().iterator();
		// new IRBinary(varA, IRBinary.Op.Add, varA, varC)
		assertEquals(new IRBinary(varA, IRBinary.Op.Add, varA, varC), i.next());
		// new IRBinary(varA, IRBinary.Op.Add, varA, varA)
		assertEquals(new IRBinary(varA, IRBinary.Op.Add, varA, varA), i.next());
		// new IRBinary(varA, IRBinary.Op.Add, varB, varC)
		assertEquals(new IRMove(varA, varB), i.next());
		assertEquals(new IRBinary(varA, IRBinary.Op.Add, varA, varC), i.next());
		// new IRBinary(varA, IRBinary.Op.Add, varB, varA) -> swapped
		assertEquals(new IRBinary(varA, IRBinary.Op.Add, varA, varB), i.next());

		// new IRBinary(varA, IRBinary.Op.Add, varA, 1)
		assertEquals(new IRBinary(varA, IRBinary.Op.Add, varA, 1), i.next());
		// new IRBinary(varA, IRBinary.Op.Add, varB, 1)
		assertEquals(new IRMove(varA, varB), i.next());
		assertEquals(new IRBinary(varA, IRBinary.Op.Add, varA, 1), i.next());

		// new IRBinary(varA, IRBinary.Op.Sub, varA, varC)
		assertEquals(new IRBinary(varA, IRBinary.Op.Sub, varA, varC), i.next());
		// new IRBinary(varA, IRBinary.Op.Sub, varA, varA)
		assertEquals(new IRBinary(varA, IRBinary.Op.Sub, varA, varA), i.next());
		// new IRBinary(varA, IRBinary.Op.Sub, varB, varC)
		assertEquals(new IRMove(varA, varB), i.next());
		assertEquals(new IRBinary(varA, IRBinary.Op.Sub, varA, varC), i.next());
		// new IRBinary(varA, IRBinary.Op.Sub, varB, varA)
		assertEquals(new IRMove(varTmp1, varB), i.next());
		assertEquals(new IRBinary(varTmp1, IRBinary.Op.Sub, varTmp1, varA), i.next());
		assertEquals(new IRMove(varA, varTmp1), i.next());

		// new IRBinary(varA, IRBinary.Op.Sub, varA, 1)
		assertEquals(new IRBinary(varA, IRBinary.Op.Sub, varA, 1), i.next());
		// new IRBinary(varA, IRBinary.Op.Sub, varB, 1)
		assertEquals(new IRMove(varA, varB), i.next());
		assertEquals(new IRBinary(varA, IRBinary.Op.Sub, varA, 1), i.next());
		assertFalse(i.hasNext());

		final Iterator<IRVarDef> d = result.second().vars().iterator();
		assertEquals(new IRVarDef(varA, 2), d.next());
		assertEquals(new IRVarDef(varB, 2), d.next());
		assertEquals(new IRVarDef(varC, 2), d.next());
		assertEquals(new IRVarDef(varTmp1, 2), d.next());
		assertFalse(d.hasNext());
	}
}
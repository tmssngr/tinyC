package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.ast.*;
import com.regnis.tinyc.ir.*;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.assertEquals;

/**
 * @author Thomas Singer
 */
public class LSParallelMoveTest {

	@Test
	public void test() {
		final IRVar a = new IRVar("a", 0, VariableScope.function, Type.I16);
		final IRVar b = new IRVar("b", 1, VariableScope.function, Type.I16);
		final IRVar c = new IRVar("c", 2, VariableScope.function, Type.I16);
		final IRVar d = new IRVar("d", 3, VariableScope.function, Type.I16);
		final IRVar e = new IRVar("e", 4, VariableScope.function, Type.I16);

		final List<LSParallelMove.VarTransfer> transfers = new ArrayList<>();
		LSParallelMove.transfer(List.of(), 1, transfers::add);
		assertEquals(List.of(), transfers);

		// vars -> registers
		LSParallelMove.transfer(List.of(
				new LSParallelMove.VarTransfer(a, -1, 0),
				new LSParallelMove.VarTransfer(b, -1, 1)
		), 3, transfers::add);
		assertEquals(List.of(
				new LSParallelMove.VarTransfer(a, -1, 0),
				new LSParallelMove.VarTransfer(b, -1, 1)
		), transfers);

		// registers -> vars
		transfers.clear();
		LSParallelMove.transfer(List.of(
				new LSParallelMove.VarTransfer(a, 0, -1),
				new LSParallelMove.VarTransfer(b, 1, -1)
		), 3, transfers::add);
		assertEquals(List.of(
				new LSParallelMove.VarTransfer(a, 0, -1),
				new LSParallelMove.VarTransfer(b, 1, -1)
		), transfers);

		// multi-move
		transfers.clear();
		LSParallelMove.transfer(List.of(
				new LSParallelMove.VarTransfer(a, 0, 1),
				new LSParallelMove.VarTransfer(b, 1, 2)
		), 3, transfers::add);
		assertEquals(List.of(
				new LSParallelMove.VarTransfer(b, 1, 2),
				new LSParallelMove.VarTransfer(a, 0, 1)
		), transfers);

		// circular-move
		transfers.clear();
		LSParallelMove.transfer(List.of(
				new LSParallelMove.VarTransfer(a, 0, 1),
				new LSParallelMove.VarTransfer(b, 1, 0)
		), 3, transfers::add);
		assertEquals(List.of(
				new LSParallelMove.VarTransfer(a, 0, 2),
				new LSParallelMove.VarTransfer(b, 1, 0),
				new LSParallelMove.VarTransfer(a, 2, 1)
		), transfers);

		// multiple circles, no free reg
		transfers.clear();
		LSParallelMove.transfer(List.of(
				new LSParallelMove.VarTransfer(a, 0, 1),
				new LSParallelMove.VarTransfer(b, 1, 0),

				new LSParallelMove.VarTransfer(c, 3, 2),
				new LSParallelMove.VarTransfer(d, 2, 4),
				new LSParallelMove.VarTransfer(e, 4, 3)
		), 5, transfers::add);
		assertEquals(List.of(
				new LSParallelMove.VarTransfer(a, 0, -1),
				new LSParallelMove.VarTransfer(b, 1, 0),
				new LSParallelMove.VarTransfer(a, -1, 1),

				new LSParallelMove.VarTransfer(c, 3, -1),
				new LSParallelMove.VarTransfer(e, 4, 3),
				new LSParallelMove.VarTransfer(d, 2, 4),
				new LSParallelMove.VarTransfer(c, -1, 2)
		), transfers);
	}
}
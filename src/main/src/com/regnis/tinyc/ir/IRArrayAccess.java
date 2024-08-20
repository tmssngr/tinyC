package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRArrayAccess(@NotNull IRVar addr, @NotNull IRVar array, @NotNull IRVar index, @NotNull Location location) implements IRInstruction {
	public IRArrayAccess {
		Utils.assertTrue(addr.type().isPointer());
		Utils.assertTrue(array.type().isPointer());
		Utils.assertTrue(Objects.equals(addr.type(), array.type()));
	}

	@Override
	public String toString() {
		return "array " + addr + ", " + array + " + " + index;
	}
}

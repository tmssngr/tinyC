package com.regnis.tinyc.ir;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record IRMove(@NotNull IRVar target, @NotNull IRVar source, @NotNull Location location) implements IRInstruction {
	public IRMove {
		Utils.assertTrue(Objects.equals(target.type(), source.type()));
	}

	@Override
	public String toString() {
		return "move " + target + ", " + source;
	}
}

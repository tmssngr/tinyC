package com.regnis.tinyc.ast;

import com.regnis.tinyc.types.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface Statement {
	@NotNull
	Statement determineTypes(VariableTypes types);

	interface Simple extends Statement {
		@NotNull
		@Override
		Simple determineTypes(VariableTypes types);
	}
}

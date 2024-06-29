package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;
import com.regnis.tinyc.types.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface Expression {
	@NotNull
	Expression determineType(@NotNull VariableTypes types);

	@NotNull
	Type typeNotNull();

	@NotNull
	Location location();
}

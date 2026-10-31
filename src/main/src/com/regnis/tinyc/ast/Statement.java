package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface Statement {
	@NotNull
	Location location();
}

package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

/**
 * @author Thomas Singer
 */
public interface SimpleStatement extends Statement {
	record Assign(String varName, AstNode expression, Location location) implements SimpleStatement {
	}
}

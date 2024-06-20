package com.regnis.tinyc.ast;

/**
 * @author Thomas Singer
 */
public enum NodeType {
	Chain, IntLit, VarRead, VarLhs, Assign, Print,
	Add, Sub, Multiply, Divide,
	Lt, LtEq, Equals, NotEquals, GtEq, Gt
}

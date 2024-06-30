package com.regnis.tinyc.ast;

import java.util.*;

/**
 * @author Thomas Singer
 */
public record StmtCompound(List<Statement> statements) implements Statement {
}

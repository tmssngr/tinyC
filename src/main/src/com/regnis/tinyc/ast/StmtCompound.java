package com.regnis.tinyc.ast;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtCompound(@NotNull List<Statement> statements) implements Statement {
}

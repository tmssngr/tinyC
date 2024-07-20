package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtIf(@NotNull Expression condition, @NotNull List<Statement> thenStatements, @NotNull List<Statement> elseStatements, @NotNull Location location) implements Statement {
}

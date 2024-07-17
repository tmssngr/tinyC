package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtLoop(@NotNull Expression condition, @NotNull Statement bodyStatement, @NotNull List<Statement> iteration, @NotNull Location location) implements Statement {
}

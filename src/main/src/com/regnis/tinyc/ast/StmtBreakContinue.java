package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record StmtBreakContinue(boolean isBreak, @NotNull Location location) implements Statement {
}

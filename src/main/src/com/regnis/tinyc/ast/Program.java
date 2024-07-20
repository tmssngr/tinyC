package com.regnis.tinyc.ast;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Program(@NotNull List<Statement> globalVars,
                      @NotNull List<Function> functions,
                      @NotNull List<Variable> globalVariables,
                      @NotNull List<StringLiteral> stringLiterals) {
}

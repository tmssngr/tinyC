package com.regnis.tinyc.ast;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public record Program(@NotNull List<StmtVarDeclaration> globalVars, @NotNull List<Function> functions) {
}

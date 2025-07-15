package com.regnis.tinyc.linearscanregalloc;

import com.regnis.tinyc.ast.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface LSTypeRegisterCountProvider {

	int registerCount(@NotNull Type type);

	boolean canUseRegister(@NotNull Type type, int register);
}

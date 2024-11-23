package com.regnis.tinyc.ir;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public interface IRCanBeRegister {
	boolean canBeRegister(@NotNull IRVar var);
}

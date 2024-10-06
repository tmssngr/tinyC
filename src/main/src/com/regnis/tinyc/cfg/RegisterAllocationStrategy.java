package com.regnis.tinyc.cfg;

/**
 * @author Thomas Singer
 */
public record RegisterAllocationStrategy(int maxVolatileRegisterCount, int maxCalleeSavedRegisterCount,
                                         int maxCallArgRegisters, int firstCallArgRegister) {
}

package com.regnis.tinyc.ir;

import com.regnis.tinyc.ast.*;

import java.util.*;

import org.junit.*;

/**
 * @author Thomas Singer
 */
public class IRLocalVarFactoryTest {

	@Test
	public void test1() {
		final IRVarInfos globalVarInfos = new IRVarInfos(List.of(), Set.of(), null);
		final IRVar u8_a = new IRVar("a", 0, VariableScope.parameter, Type.U8);
		final IRVar param_u8_a = new IRVar("param.a", 1, VariableScope.function, Type.U8);
		final IRVar stack_param_u8_a = new IRVar("arg.param.a", 2, VariableScope.function, Type.U8);
		final IRLocalVarFactory factory = new IRLocalVarFactory(new IRVarInfos(List.of(
				new IRVarDef(u8_a, 1)
		), Set.of(), globalVarInfos), Type.I64);
		final IRVar param_a = factory.createVar(u8_a, "param." + u8_a.name());
		Assert.assertEquals(param_u8_a, param_a);
		final IRVar stackArgVar = factory.createStackArgVar(Type.U8, "arg." + param_a.name());
		Assert.assertEquals(stack_param_u8_a, stackArgVar);

		final IRVarInfos derivedVarInfos = factory.createVarInfos();
		Assert.assertEquals(new IRVarInfos(List.of(
				                    new IRVarDef(u8_a, 1),
				                    new IRVarDef(param_u8_a, 1),
				                    new IRVarDef(stack_param_u8_a, 1)
		                    ), Set.of(
									stack_param_u8_a
		                    ), globalVarInfos),
		                    derivedVarInfos);
	}
}
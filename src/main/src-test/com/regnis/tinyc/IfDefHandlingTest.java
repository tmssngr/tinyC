package com.regnis.tinyc;

import java.util.*;

import org.junit.*;

import static org.junit.Assert.*;

/**
 * @author Thomas Singer
 */
public class IfDefHandlingTest {

	@Test
	public void testSingleIf() {
		final IfDefHandling idh = new IfDefHandling(Set.of("a"));
		assertFalse(idh.isSkip());
		idh.ifDef("b", new Location(1, 0));
		{
			assertTrue(idh.isSkip());
		}
		idh.endif(new Location(2, 0));
		assertFalse(idh.isSkip());

		idh.ifDef("a", new Location(3, 0));
		{
			assertFalse(idh.isSkip());
		}

		idh.endif(new Location(4, 0));
		assertFalse(idh.isSkip());

		idh.eof();
	}

	@Test
	public void testNestedIf() {
		final IfDefHandling idh = new IfDefHandling(Set.of("a"));
		assertFalse(idh.isSkip());
		idh.ifDef("b", new Location(1, 0));
		{
			assertTrue(idh.isSkip());
			idh.ifDef("a", new Location(2, 0));
			assertTrue(idh.isSkip());
			idh.endif(new Location(3, 0));
			assertTrue(idh.isSkip());
		}
		idh.endif(new Location(4, 0));
		assertFalse(idh.isSkip());

		idh.ifDef("a", new Location(5, 0));
		{
			assertFalse(idh.isSkip());
			idh.ifDef("b", new Location(6, 0));
			{
				assertTrue(idh.isSkip());
			}
			idh.endif(new Location(7, 0));
			assertFalse(idh.isSkip());
		}

		idh.endif(new Location(8, 0));
		assertFalse(idh.isSkip());

		idh.eof();
	}

	@Test
	public void testIllegal() {
		final IfDefHandling idh = new IfDefHandling(Set.of("a"));
		assertFalse(idh.isSkip());
		try {
			idh.endif(new Location(37, 10));
		}
		catch (SyntaxException ex) {
			assertEquals(Messages.endifWithoutIfdef(), ex.getMessage());
		}

		idh.ifDef("a", new Location(0, 0));
		try {
			idh.eof();
		}
		catch (SyntaxException ex) {
			assertEquals(Messages.unclosedIfdef(), ex.getMessage());
		}
	}
}
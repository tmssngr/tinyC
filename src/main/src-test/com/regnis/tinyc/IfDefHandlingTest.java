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
		idh.processIfDef("b", new Location(1, 0));
		{
			assertTrue(idh.isSkip());
		}
		idh.processEndIf(new Location(2, 0));
		assertFalse(idh.isSkip());

		idh.processIfDef("a", new Location(3, 0));
		{
			assertFalse(idh.isSkip());
		}

		idh.processEndIf(new Location(4, 0));
		assertFalse(idh.isSkip());

		idh.eof();
	}

	@Test
	public void testSingleIfElse() {
		final IfDefHandling idh = new IfDefHandling(Set.of("a"));
		assertFalse(idh.isSkip());
		idh.processIfDef("b", new Location(1, 0));
		{
			assertTrue(idh.isSkip());
		}
		idh.processElse(new Location(2, 0));
		{
			assertFalse(idh.isSkip());
		}
		idh.processEndIf(new Location(3, 0));
		assertFalse(idh.isSkip());

		idh.processIfDef("a", new Location(4, 0));
		{
			assertFalse(idh.isSkip());
		}
		idh.processElse(new Location(5, 0));
		{
			assertTrue(idh.isSkip());
		}
		idh.processEndIf(new Location(6, 0));
		assertFalse(idh.isSkip());

		idh.eof();
	}

	@Test
	public void testNestedIf() {
		final IfDefHandling idh = new IfDefHandling(Set.of("a"));
		assertFalse(idh.isSkip());
		idh.processIfDef("b", new Location(1, 0));
		{
			assertTrue(idh.isSkip());
			idh.processIfDef("a", new Location(2, 0));
			assertTrue(idh.isSkip());
			idh.processEndIf(new Location(3, 0));
			assertTrue(idh.isSkip());
		}
		idh.processEndIf(new Location(4, 0));
		assertFalse(idh.isSkip());

		idh.processIfDef("a", new Location(5, 0));
		{
			assertFalse(idh.isSkip());
			idh.processIfDef("b", new Location(6, 0));
			{
				assertTrue(idh.isSkip());
			}
			idh.processEndIf(new Location(7, 0));
			assertFalse(idh.isSkip());
		}

		idh.processEndIf(new Location(8, 0));
		assertFalse(idh.isSkip());

		idh.eof();
	}

	@Test
	public void testNestedIfElse() {
		final IfDefHandling idh = new IfDefHandling(Set.of("a"));
		assertFalse(idh.isSkip());
		idh.processIfDef("b", new Location(1, 0));
		{
			{
				assertTrue(idh.isSkip());
				idh.processIfDef("a", new Location(2, 0));
				{
					{
						assertTrue(idh.isSkip());
					}
					idh.processElse(new Location(3, 0));
					{
						assertTrue(idh.isSkip());
					}
				}
				idh.processEndIf(new Location(4, 0));
				assertTrue(idh.isSkip());
			}
			idh.processElse(new Location(5, 0));
			{
				assertFalse(idh.isSkip());
				idh.processIfDef("a", new Location(6, 0));
				{
					{
						assertFalse(idh.isSkip());
					}
					idh.processElse(new Location(7, 0));
					{
						assertTrue(idh.isSkip());
					}
				}
				idh.processEndIf(new Location(8, 0));
				assertFalse(idh.isSkip());
			}
		}
		idh.processEndIf(new Location(9, 0));
		assertFalse(idh.isSkip());

		idh.processIfDef("a", new Location(10, 0));
		{
			{
				assertFalse(idh.isSkip());
				idh.processIfDef("b", new Location(11, 0));
				{
					{
						assertTrue(idh.isSkip());
					}
					idh.processElse(new Location(12, 0));
					{
						assertFalse(idh.isSkip());
					}
				}
				idh.processEndIf(new Location(13, 0));
				assertFalse(idh.isSkip());
			}
			idh.processElse(new Location(14, 0));
			{
				assertTrue(idh.isSkip());
				idh.processIfDef("b", new Location(15, 0));
				{
					{
						assertTrue(idh.isSkip());
					}
					idh.processElse(new Location(16, 0));
					{
						assertTrue(idh.isSkip());
					}
				}
				idh.processEndIf(new Location(17, 0));
				assertTrue(idh.isSkip());
			}
		}
		idh.processEndIf(new Location(18, 0));
		assertFalse(idh.isSkip());

		idh.eof();
	}

	@Test
	public void testIllegal() {
		final IfDefHandling idh = new IfDefHandling(Set.of("a"));
		assertFalse(idh.isSkip());
		try {
			idh.processEndIf(new Location(37, 10));
		}
		catch (SyntaxException ex) {
			assertEquals(Messages.endifWithoutIfdef(), ex.getMessage());
		}

		idh.processIfDef("a", new Location(0, 0));
		try {
			idh.eof();
		}
		catch (SyntaxException ex) {
			assertEquals(Messages.unclosedIfdef(), ex.getMessage());
		}
	}
}
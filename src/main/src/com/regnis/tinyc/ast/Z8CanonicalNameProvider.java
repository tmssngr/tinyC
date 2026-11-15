package com.regnis.tinyc.ast;

import com.regnis.tinyc.*;

import java.util.*;

import org.jetbrains.annotations.*;

/**
 * @author Thomas Singer
 */
public final class Z8CanonicalNameProvider implements TypeChecker.CanonicalNameProvider {
	@NotNull
	@Override
	public String canonicalFunctionName(@NotNull String name, @NotNull List<Type> types) {
		Utils.assertTrue(name.indexOf('@') < 0);

		final StringBuilder buffer = new StringBuilder();
		escape(name, buffer);
		for (Type type : types) {
			buffer.append("_P");
			while (type.isPointer()) {
				buffer.append("_p");
				type = type.toType();
				assert type != null;
			}
			final String typeString = type.toString();
			Utils.assertTrue(typeString.indexOf('@') < 0);
			escape(typeString, buffer);
		}
		return buffer.toString();
	}

	private void escape(String name, StringBuilder buffer) {
		for (int i = 0; i < name.length(); i++) {
			final char chr = name.charAt(i);
			if (Utils.isInInterval(chr, '0', '9')
			    || Utils.isInInterval(chr, 'A', 'Z')
			    || Utils.isInInterval(chr, 'a', 'z')) {
				buffer.append(chr);
				continue;
			}
			// '_' -> "__"
			if (chr == '_') {
				buffer.append(chr);
				buffer.append(chr);
				continue;
			}
			if (chr < 0x80) {
				buffer.append("_");
				buffer.append(Utils.toHex(chr, 2));
				continue;
			}

			buffer.append("_u");
			buffer.append(Utils.toHex(chr, 4));
		}
	}
}

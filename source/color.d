module color;

import std.conv : to;
import std.process : environment;

enum Style {
	Bold,
	Italic,
	Underline,
	Dim,
}

const string RESET     = "\x1b[0m";
const string BOLD      = "\x1b[1m";
const string DIM       = "\x1b[2m";
const string ITALIC    = "\x1b[3m";
const string UNDERLINE = "\x1b[4m";

const uint ERROR = 0xFC5549;
const uint WARN  = 0xFCAE49;
const uint INFO  = 0x74B5E8;

final class RGB {
	private bool noColor;
	private ubyte r, g, b;
	private Style[] styles;

	this(ubyte r, ubyte g, ubyte b) {
		this.r = r;
		this.g = g;
		this.b = b;
		auto col = environment.get("NO_COLOR");
		this.noColor = col !is null && col[0] != '\0';
	}
	this(ubyte r, ubyte g, ubyte b, Style[] style...) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.styles = style;
		auto col = environment.get("NO_COLOR");
		this.noColor = col !is null && col[0] != '\0';
	}
	this(uint rgb) {
		import std.bitmanip : nativeToBigEndian;
		// [NIL, R, G, B];
		ubyte[4] colArr = nativeToBigEndian(rgb);
		this.r = colArr[1];
		this.g = colArr[2];
		this.b = colArr[3];
		auto col = environment.get("NO_COLOR");
		this.noColor = col !is null && col[0] != '\0';
	}
	this(uint rgb, Style[] style...) {
		import std.bitmanip : nativeToBigEndian;
		// [NIL, R, G, B];
		ubyte[4] colArr = nativeToBigEndian(rgb);
		this.r = colArr[1];
		this.g = colArr[2];
		this.b = colArr[3];
		this.styles = style;
		auto col = environment.get("NO_COLOR");
		this.noColor = col !is null && col[0] != '\0';
	}

	void addStyles(Style[] style...) {
		this.styles ~= style;
	}

	ref bool getNoColor() {
		return noColor;
	}

	private string styleAsString(Style style) const nothrow {
		switch (style) {
			case Style.Bold: return BOLD;
			case Style.Italic: return ITALIC;
			case Style.Underline: return UNDERLINE;
			case Style.Dim: return DIM;
			default: return RESET;
		}
	}

	override string toString() const nothrow {
		string res;
		if (!noColor && styles.length == 1) {
			res ~= styleAsString(styles[0]);
		} 
		else if (!noColor && styles.length > 1) {
			foreach (style; styles) {
				res ~= styleAsString(style);
			}
		}
		else if (noColor) {
			return res;
		}
		res ~= "\x1b[38;2;";
		res ~= to!string(r) ~ ';';
		res ~= to!string(g) ~ ';';
		res ~= to!string(b) ~ 'm';
		return res;
	}
}

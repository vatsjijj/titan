module lexer;

import std.uni;
import std.conv : to;

enum TokenKind {
	Number,
	Char,
	Identifier,
	Quote,
	Plus, Minus,
	Mult, Div,
	Modulo,
	Union,
	Intersection,
	Apply,
	Enquote,
	Dup,
	Equality,
	Display,
	Assign,
	Slash,
	Snatch,
	NotEqu,
	Less, Greater,
	LessEqu, GreaterEqu,
	MovStack2, TakeStack2,
	Cardinality,
	Import,
	Absolute,
}

private struct TokenHolder {
	TokenKind kind;
	wstring content;
	ulong line, col, len;
}

struct TokenPrimitive {
	TokenHolder holder;
	union {
		double num;
		wchar chr;
	}

	this(TokenKind kind, wstring content, ulong line, ulong col) {
		this.holder.kind = kind;
		this.holder.content = content;
		this.holder.line = line;
		this.holder.col = col;
		this.holder.len = content.length;
		convert();
	}

	void convert() {
		if (holder.kind == TokenKind.Number) {
			num = to!double(holder.content);
		}
		else if (holder.kind == TokenKind.Char) {
			chr = holder.content[0];
		}
	}
}

struct TokenQuoted {
	TokenHolder holder;
	Container[] toks;
	ulong endLine, endCol;

	this(ulong line, ulong col, ulong endLine, ulong endCol) {
		this.holder.kind = TokenKind.Quote;
		this.holder.line = line;
		this.holder.col = col;
		this.endLine = endLine;
		this.endCol = endCol;
		this.holder.len = endCol - this.holder.col;
	}

	void set(ulong line, ulong col, ulong endLine, ulong endCol) {
		this.holder.kind = TokenKind.Quote;
		this.holder.line = line;
		this.holder.col = col;
		this.endLine = endLine;
		this.endCol = endCol;
		this.holder.len = endCol - this.holder.col;
	}
}

struct Container {
	bool isPrim;
	union {
		TokenPrimitive prim;
		TokenQuoted quote;
	}

	this(TokenPrimitive prim) {
		this.isPrim = true;
		this.prim = prim;
	}
	this(TokenQuoted quote) {
		this.isPrim = false;
		this.quote = quote;
	}

	bool isKind(TokenKind kind) {
		if (isPrim) return prim.holder.kind == kind;
		return quote.holder.kind == kind;
	}

	ref TokenKind getKind() {
		if (isPrim) return prim.holder.kind;
		return quote.holder.kind;
	}

	string strRepr(ulong indent = 0) {
		import std.conv : to;
		string tmp;
		foreach (_; 0..indent) {
			tmp ~= "   ";
		}
		tmp ~= to!string(isPrim) ~ " ";
		tmp ~= isPrim ? to!string(prim.holder.kind) : to!string(quote.holder.kind);
		tmp ~= "\n";
		if (isPrim) {
			foreach (_; 0..indent + 1) {
				tmp ~= "   ";
			}
			tmp ~= to!string(prim.holder.content) ~ '\n';
		}
		if (!isPrim) {
			foreach (tok; quote.toks) {
				tmp ~= tok.strRepr(indent + 1);
			}
		}
		return tmp;
	}

	bool equals(ref Container cont) {
		if (this.isPrim != cont.isPrim) return false;
		if (this.isPrim) {
			if (this.prim.holder.kind != cont.prim.holder.kind) return false;
			if (this.prim.holder.kind == TokenKind.Number) {
				return this.prim.num == cont.prim.num;
			}
			else if (this.prim.holder.kind == TokenKind.Char) {
				return this.prim.chr == cont.prim.chr;
			}
			return false;
		}
		else {
			if (this.quote.toks.length != cont.quote.toks.length) return false;
			if (this.quote.toks.length == 0 && cont.quote.toks.length == 0) return true;
			foreach (i; 0..(this.quote.toks.length - 1)) {
				if (!this.quote.toks[i].equals(cont.quote.toks[i])) return false;
			}
			return true;
		}
	}
}

final class Lexer {
	private ulong ip, line, col;
	private Container[] toks;
	wstring file;

	this(ref wstring file) {
		this.file = file;
		this.ip = 0;
		this.line = 1;
		this.col = 1;
	}

	private void toss(string msg) {
		import core.stdc.stdlib : exit;
		import std.stdio;
		stderr.writeln(
			"Fatal lexical error at ", this.line, ":", this.col,
			": ", msg
		);
		exit(1);
	}

	private bool isChar(wchar[] chs...) {
		foreach (ch; chs) {
			if (file[ip] == ch) return true;
		}
		return false;
	}

	private void whitespace() {
		while (isWhite(file[ip])) {
			if (file[ip] == '\n') {
				ip++;
				line++;
				col = 1;
			}
			else {
				col++;
				ip++;
			}
		}
	}

	private void identifier() {
		ulong tmpLine = this.line;
		ulong tmpCol = this.col;
		wstring tmp;
		while (!isWhite(file[ip]) && !isChar('"', '`', '[', ']')) {
			tmp ~= file[ip];
			ip++;
			col++;
		}
		switch (tmp) {
			case "+":
				toks ~= Container(TokenPrimitive(TokenKind.Plus, tmp, tmpLine, tmpCol));
				break;
			case "-":
				toks ~= Container(TokenPrimitive(TokenKind.Minus, tmp, tmpLine, tmpCol));
				break;
			case "×":
				toks ~= Container(TokenPrimitive(TokenKind.Mult, tmp, tmpLine, tmpCol));
				break;
			case "÷":
				toks ~= Container(TokenPrimitive(TokenKind.Div, tmp, tmpLine, tmpCol));
				break;
			case "%":
				toks ~= Container(TokenPrimitive(TokenKind.Modulo, tmp, tmpLine, tmpCol));
				break;
			case "∪":
				toks ~= Container(TokenPrimitive(TokenKind.Union, tmp, tmpLine, tmpCol));
				break;
			case "∩":
				toks ~= Container(TokenPrimitive(TokenKind.Intersection, tmp, tmpLine, tmpCol));
				break;
			case "∘":
				toks ~= Container(TokenPrimitive(TokenKind.Apply, tmp, tmpLine, tmpCol));
				break;
			case "'":
				toks ~= Container(TokenPrimitive(TokenKind.Enquote, tmp, tmpLine, tmpCol));
				break;
			case ":":
				toks ~= Container(TokenPrimitive(TokenKind.Dup, tmp, tmpLine, tmpCol));
				break;
			case "=":
				toks ~= Container(TokenPrimitive(TokenKind.Equality, tmp, tmpLine, tmpCol));
				break;
			case "==":
				toks ~= Container(TokenPrimitive(TokenKind.Assign, tmp, tmpLine, tmpCol));
				break;
			case ".":
				toks ~= Container(TokenPrimitive(TokenKind.Display, tmp, tmpLine, tmpCol));
				break;
			case "/":
				toks ~= Container(TokenPrimitive(TokenKind.Slash, tmp, tmpLine, tmpCol));
				break;
			case "⋄":
				toks ~= Container(TokenPrimitive(TokenKind.Snatch, tmp, tmpLine, tmpCol));
				break;
			case "≠":
				toks ~= Container(TokenPrimitive(TokenKind.NotEqu, tmp, tmpLine, tmpCol));
				break;
			case "<":
				toks ~= Container(TokenPrimitive(TokenKind.Less, tmp, tmpLine, tmpCol));
				break;
			case ">":
				toks ~= Container(TokenPrimitive(TokenKind.Greater, tmp, tmpLine, tmpCol));
				break;
			case "≤":
				toks ~= Container(TokenPrimitive(TokenKind.LessEqu, tmp, tmpLine, tmpCol));
				break;
			case "≥":
				toks ~= Container(TokenPrimitive(TokenKind.GreaterEqu, tmp, tmpLine, tmpCol));
				break;
			case ">s":
				toks ~= Container(TokenPrimitive(TokenKind.MovStack2, tmp, tmpLine, tmpCol));
				break;
			case "<s":
				toks ~= Container(TokenPrimitive(TokenKind.TakeStack2, tmp, tmpLine, tmpCol));
				break;
			case "#":
				toks ~= Container(TokenPrimitive(TokenKind.Cardinality, tmp, tmpLine, tmpCol));
				break;
			case "using":
				toks ~= Container(TokenPrimitive(TokenKind.Import, tmp, tmpLine, tmpCol));
				break;
			case "|":
				toks ~= Container(TokenPrimitive(TokenKind.Absolute, tmp, tmpLine, tmpCol));
				break;
			default:
				toks ~= Container(TokenPrimitive(TokenKind.Identifier, tmp, tmpLine, tmpCol));
				break;
		}
	}

	private void number() {
		ulong tmpLine = this.line;
		ulong tmpCol = this.col;
		wstring tmp;
		if (isChar('¬')) {
			tmp ~= '-';
			ip++;
			col++;
		}
		while (isNumber(file[ip])) {
			tmp ~= file[ip];
			ip++;
			col++;
		}
		if (isChar('.')) {
			tmp ~= file[ip];
			ip++;
			col++;
			while (isNumber(file[ip])) {
				tmp ~= file[ip];
				ip++;
				col++;
			}
		}
		toks ~= Container(TokenPrimitive(TokenKind.Number, tmp, tmpLine, tmpCol));
	}

	private void chr() {
		ulong tmpLine = this.line;
		ulong tmpCol = this.col;
		wstring tmp;
		ip++;
		col++;
		if (file[ip] == '%' && file[ip + 1] == 'n') {
			tmp ~= '\n';
			ip++;
			ip++;
			col++;
			col++;
		}
		else {
			tmp ~= file[ip];
			ip++;
			col++;
		}
		if (!isChar('`')) toss("Expected GRAVE.");
		ip++;
		col++;
		toks ~= Container(TokenPrimitive(TokenKind.Char, tmp, tmpLine, tmpCol));
	}

	private Container chrNoGrave() {
		ulong tmpLine = this.line;
		ulong tmpCol = this.col;
		wstring tmp;
		tmp ~= file[ip];
		ip++;
		col++;
		return Container(TokenPrimitive(TokenKind.Char, tmp, tmpLine, tmpCol));
	}

	private void str() {
		TokenQuoted quote;
		ulong tmpLine = this.line;
		ulong tmpCol = this.col;
		ip++;
		col++;
		while (!isChar('"', '\n')) {
			quote.toks ~= chrNoGrave();
		}
		ulong endLine = this.line;
		ulong endCol = this.col;
		ip++;
		col++;
		quote.set(tmpLine, tmpCol, endLine, endCol);
		toks ~= Container(quote);
	}

	private void quote() {
		TokenQuoted quote;
		ulong tmpLine = this.line;
		ulong tmpCol = this.col;
		ulong nestLevel = 0;
		wstring tmp;
		ip++;
		col++;
		nestLevel++;
		while (nestLevel != 0) {
			if (isChar('[')) nestLevel++;
			else if (isChar(']')) {
				if (nestLevel == 1) {
					nestLevel--;
					ip++;
					col++;
					break;
				}
				nestLevel--;
			}
			tmp ~= file[ip];
			ip++;
			col++;
		}
		ulong endLine = this.line;
		ulong endCol = this.col;
		tmp ~= '\n';
		Lexer tmpLexer = new Lexer(tmp);
		tmpLexer.tokenize();
		quote = TokenQuoted(tmpLine, tmpCol, endLine, endCol);
		quote.toks = tmpLexer.getToks();
		toks ~= Container(quote);
	}

	private void comment() {
		while (!isChar('\n')) {
			ip++;
			col++;
		}
	}

	void tokenize() {
		while (ip < file.length) {
			if (isWhite(file[ip])) {
				whitespace();
			}
			else if (isChar('⋮')) {
				comment();
			}
			else if (isNumber(file[ip]) || isChar('¬')) {
				number();
			}
			else if (isChar('`')) {
				chr();
			}
			else if (isChar('"')) {
				str();
			}
			else if (!isChar('"', '`', '[', ']')) {
				identifier();
			}
			else if (isChar('[')) {
				quote();
			}
		}
	}

	ref Container[] getToks() {
		return this.toks;
	}
}
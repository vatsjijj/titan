module pass;

import std.conv : to;
import lexer;

struct Function {
	TokenPrimitive fn;
	TokenQuoted quote;

	this(ref TokenPrimitive fn, ref TokenQuoted quote) {
		this.fn = fn;
		this.quote = quote;
	}
}

final class RuntimeContainer {
	private Function[wstring] funcTable;
	private ulong ip;
	private Container[] toks;

	this(ref Container[] toks) {
		this.toks = toks;
		this.ip = 0;
	}

	bool exists(ref wstring key) => (key in funcTable) !is null;

	private ref Container curr() => toks[ip];
	private ref Container peek() => toks[ip + 1];

	private bool atEnd() => ip + 1 == toks.length;

	private void toss(string msg) {
		import core.stdc.stdlib : exit;
		import std.stdio;
		auto tok = curr();
		stderr.writeln(
			"Fatal parse error at ",
			tok.isPrim ? tok.prim.holder.line : tok.quote.holder.line,
			":",
			tok.isPrim ? tok.prim.holder.col : tok.quote.holder.col,
			": ", msg
		);
		exit(3);
	}

	private void handleAssignment() {
		auto ident = curr();
		ip++;
		ip++;
		if (!curr().isKind(TokenKind.Quote)) toss("Expected a quote.");
		auto quote = curr();
		ip++;
		funcTable[ident.prim.holder.content] = Function(ident.prim, quote.quote);
	}

	void pass() {
		while (ip < toks.length) {
			if (
				curr().isKind(TokenKind.Identifier)
				&& !atEnd()
				&& peek().isKind(TokenKind.Assign)
			) {
				handleAssignment();
			}
			else {
				ip++;
			}
		}
	}

	ref Function[wstring] table() => this.funcTable;
}
module pass;

import std.conv : to;
import std.string;
import std.stdio;
import std.file;
import lexer;
import error;

struct Function {
	TokenPrimitive fn;
	TokenQuoted quote;

	this(ref TokenPrimitive fn, ref TokenQuoted quote) {
		this.fn = fn;
		this.quote = quote;
	}
}

final class RuntimeContainer {
	private bool[wstring] importTable;
	private Function[wstring] funcTable;
	private ulong ip;
	private Container[] toks;
	private string cwd;
	TitanError err;

	this(ref Container[] toks, string cwd, string fn) {
		this.toks = toks;
		this.ip = 0;
		this.cwd = cwd;
		this.err.filename = fn;
	}
	private this(ref Container[] toks, string cwd, ref bool[wstring] importTable, string fn) {
		this.toks = toks;
		this.ip = 0;
		this.importTable = importTable;
		this.cwd = cwd;
		this.err.filename = fn;
	}

	bool exists(ref wstring key) {
		return (key in funcTable) !is null;
	}

	private ref Container curr() {
		return toks[ip];
	}

	private ref Container peek() {
		return toks[ip + 1];
	}

	private bool atEnd() {
		return ip + 1 == toks.length;
	}

	private void toss(string msg) {
		auto tok = curr();
		auto line = tok.isPrim ? tok.prim.holder.line : tok.quote.holder.line;
		auto col = tok.isPrim ? tok.prim.holder.col : tok.quote.holder.col;
		err.message = msg;
		err.line = line;
		err.col = col;
		err.display(2);
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

	private void handleImport() {
		ip++;
		auto ident = curr();
		ip++;
		auto splitIdent = ident.prim.holder.content.split('.');
		wstring currIdent = to!wstring(cwd) ~ '/';
		foreach (i; 0..splitIdent.length) {
			currIdent ~= splitIdent[i];
			if (i != splitIdent.length - 1) currIdent ~= '/';
		}
		currIdent ~= ".ttn";
		if (currIdent in importTable) return;
		importTable[currIdent] = true;
		try {
			wstring file = to!wstring(readText(currIdent)) ~ '\n';
			Lexer lex = new Lexer(file, to!string(currIdent));
			lex.tokenize();
			RuntimeContainer rtc = new RuntimeContainer(lex.getToks(), cwd, importTable, to!string(currIdent));
			rtc.pass();
			foreach (k, v; rtc.funcTable) {
				this.funcTable[k] = v;
			}
		}
		catch (Exception e) {
			import core.stdc.stdlib : exit;
			stderr.writeln(e.message);
			exit(5);
		}
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
			else if (
				curr().isKind(TokenKind.Import)
				&& !atEnd()
				&& peek().isKind(TokenKind.Identifier)
			) {
				handleImport();
			}
			else {
				ip++;
			}
		}
	}

	ref Function[wstring] table() {
		return this.funcTable;
	}
}
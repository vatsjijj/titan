module compiler;

import lexer;
import serialize;
import vm : OpCode;
import error;

// TODO: Improve error reporting.

final class Compiler {
	private Lexer lex;
	private ConstantPool pool;
	private Program prog;
	private Length[wstring] usedConstant;

	this(ref Lexer lex) {
		this.lex = lex;
		this.pool = new ConstantPool();
	}

	ref ConstantPool getPool() {
		return this.pool;
	}

	ref Program getProgram() {
		return this.prog;
	}

	private bool constantExists(wstring ident) {
		return (ident in usedConstant) !is null;
	}

	private wstring getName(ref Container tok) {
		return tok.isPrim ? tok.prim.holder.content : tok.quote.holder.content;
	}

	private Length getConstant(wstring ident) {
		if (!constantExists(ident)) {
			throw new Exception("Constant does not exist.");
		}
		return *(ident in usedConstant);
	}

	void fillPool() {
		foreach (tok; lex.getToks()) {
			wstring name = getName(tok);
			if (constantExists(name)) {
				continue;
			}

			if (tok.isKind(TokenKind.Number)) {
				double d = tok.prim.num;
				usedConstant[name] = pool.add(d);
			}
			else if (tok.isKind(TokenKind.Char)) {
				wchar c = tok.prim.chr;
				usedConstant[name] = pool.add(c);
			}
			else {
				continue;
			}
		}
	}

	void compile() {
		ubyte[] res;
		ulong idx = 0;
		Container[] toks = lex.getToks();
		while (idx < toks.length) {
			Container curr = toks[idx];
			wstring name = getName(curr);
			ubyte[] emit = [];
			switch (curr.getKind()) {
				case TokenKind.Number, TokenKind.Char:
					emit ~= getConstant(name).emitl();
					break;
				case TokenKind.Plus:
					emit ~= OpCode.Add;
					break;
				case TokenKind.Display:
					emit ~= OpCode.Display;
					break;
				default:
					import std.conv : to;
					throw new Exception("Invalid operation: " ~ to!string(name));
			}
			idx++;
			res ~= emit;
		}
		this.prog = new Program(res);
	}
}

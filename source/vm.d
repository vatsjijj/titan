module vm;

import std.conv : to;
import std.algorithm.mutation : remove;
import std.stdio;
import lexer;
import pass;

enum ValueKind {
	Quote,
	Char,
	Number,
}

struct Quote {
	TokenQuoted quote;

	this(ref TokenQuoted quote) {
		this.quote = quote;
	}
	this(Value val) {
		if (val.isKind(ValueKind.Char)) {
			this.quote = TokenQuoted(
				val.chr.prim.holder.line, val.chr.prim.holder.col,
				val.chr.prim.holder.line, val.chr.prim.holder.col
			);
			this.quote.toks ~= Container(val.chr.prim);
		}
		else if (val.isKind(ValueKind.Number)) {
			this.quote = TokenQuoted(
				val.num.prim.holder.line, val.num.prim.holder.col,
				val.num.prim.holder.line, val.num.prim.holder.col
			);
			this.quote.toks ~= Container(val.num.prim);
		}
		else if (val.isKind(ValueKind.Quote)) {
			this.quote = TokenQuoted(
				val.quote.quote.holder.line, val.quote.quote.holder.col,
				val.quote.quote.endLine, val.quote.quote.endCol
			);
			this.quote.toks ~= Container(val.quote.quote);
		}
	}

	void display() {
		foreach (tok; quote.toks) {
			if (tok.isKind(TokenKind.Char)) {
				write(tok.prim.chr);
			}
			else if (tok.isKind(TokenKind.Number)) {
				write(tok.prim.num);
				write(" ");
			}
			else if (tok.isKind(TokenKind.Quote)) {
				Quote(tok.quote).display();
				write(" ");
			}
			else {
				write(tok.prim.holder.content);
				write(" ");
			}
		}
	}
}

struct Char {
	TokenPrimitive prim;
	wchar chr;

	this(ref TokenPrimitive prim) {
		this.prim = prim;
		this.chr = prim.chr;
	}
	this(wchar chr) {
		this.chr = chr;
	}

	void display() {
		write(chr);
	}
}

struct Number {
	TokenPrimitive prim;
	double num;

	this(ref TokenPrimitive prim) {
		this.prim = prim;
		this.num = prim.num;
	}
	this(double num) {
		this.num = num;
		this.prim = TokenPrimitive(TokenKind.Number, to!wstring(num), 0, 0);
		this.prim.num = num;
	}

	void display() {
		write(num);
	}
}

struct Value {
	ValueKind kind;
	union {
		Quote quote;
		Char chr;
		Number num;
	}

	this(Quote quote) {
		this.kind = ValueKind.Quote;
		this.quote = quote;
	}
	this(Char chr) {
		this.kind = ValueKind.Char;
		this.chr = chr;
	}
	this(Number num) {
		this.kind = ValueKind.Number;
		this.num = num;
	}

	bool isKind(ValueKind kind) {
		return this.kind == kind;
	}

	void display() {
		if (kind == ValueKind.Char) chr.display();
		else if (kind == ValueKind.Number) num.display();
		else if (kind == ValueKind.Quote) quote.display();
	}

	bool equals(Value val) {
		if (this.kind != val.kind) return false;
		else {
			if (kind == ValueKind.Char) {
				return chr.chr == val.chr.chr;
			}
			else if (kind == ValueKind.Number) {
				return num.num == val.num.num;
			}
			else {
				stderr.writeln("Comparison on quotes is not implemented.");
				return false;
			}
		}
	}

	bool greater(Value val) {
		if (this.kind != val.kind) return false;
		else {
			if (kind == ValueKind.Char) {
				return chr.chr > val.chr.chr;
			}
			else if (kind == ValueKind.Number) {
				return num.num > val.num.num;
			}
			else {
				stderr.writeln("Comparison on quotes is not implemented.");
				return false;
			}
		}
	}

	bool less(Value val) {
		if (this.kind != val.kind) return false;
		else {
			if (kind == ValueKind.Char) {
				return chr.chr < val.chr.chr;
			}
			else if (kind == ValueKind.Number) {
				return num.num < val.num.num;
			}
			else {
				stderr.writeln("Comparison on quotes is not implemented.");
				return false;
			}
		}
	}
}

struct Stack {
	Value[] content;

	void toss(string msg) {
		import core.stdc.stdlib : exit;
		import std.stdio;
		stderr.writeln(msg);
		exit(4);
	}

	ref Value curr() {
		return content[$ - 1];
	}

	void push(Value item) {
		content ~= item;
	}

	Value pop() {
		if (content.length == 0) toss("Stack underflow.");
		auto tmp = content[$ - 1];
		content.length--;
		return tmp;
	}

	void plus() {
		auto b = pop();
		if (!curr().isKind(ValueKind.Number) || !b.isKind(ValueKind.Number)) {
			toss("PLUS expects two numbers.");
		}
		curr().num.num += b.num.num;
		curr().num.prim.num += b.num.prim.num;
	}

	void minus() {
		auto b = pop();
		if (!curr().isKind(ValueKind.Number) || !b.isKind(ValueKind.Number)) {
			toss("MINUS expects two numbers.");
		}
		curr().num.num -= b.num.num;
		curr().num.prim.num -= b.num.prim.num;
	}

	void mult() {
		auto b = pop();
		if (!curr().isKind(ValueKind.Number) || !b.isKind(ValueKind.Number)) {
			toss("MULT expects two numbers.");
		}
		curr().num.num *= b.num.num;
		curr().num.prim.num *= b.num.prim.num;
	}

	void div() {
		auto b = pop();
		if (!curr().isKind(ValueKind.Number) || !b.isKind(ValueKind.Number)) {
			toss("DIV expects two numbers.");
		}
		curr().num.num /= b.num.num;
		curr().num.prim.num /= b.num.prim.num;
	}

	void dup() {
		push(content[$ - 1]);
	}

	void snatch() {
		if (!curr().isKind(ValueKind.Number)) {
			toss("SNATCH expects a number.");
		}
		auto item = pop();
		auto idx = (content.length - 1) - (cast(ulong)item.num.num);
		auto val = content[idx];
		content = content.remove(idx);
		push(val);
	}

	void uni() {
		auto b = pop();
		if (!curr().isKind(ValueKind.Quote) || !b.isKind(ValueKind.Quote)) {
			toss("UNION expects two quotes.");
		}
		curr().quote.quote.toks ~= b.quote.quote.toks;
	}

	void disp() {
		auto item = pop();
		item.display();
	}

	void greaterEqu() {
		auto b = pop();
		auto a = pop();
		push(Value(Number(cast(double)(a.greater(b) || a.equals(b)))));
	}

	void lessEqu() {
		auto b = pop();
		auto a = pop();
		push(Value(Number(cast(double)(a.less(b) || a.equals(b)))));
	}

	void greater() {
		auto b = pop();
		auto a = pop();
		push(Value(Number(cast(double)a.greater(b))));
	}

	void less() {
		auto b = pop();
		auto a = pop();
		push(Value(Number(cast(double)a.less(b))));
	}

	void equ() {
		auto b = pop();
		auto a = pop();
		push(Value(Number(cast(double)a.equals(b))));
	}

	void notequ() {
		auto b = pop();
		auto a = pop();
		push(Value(Number(cast(double)(!a.equals(b)))));
	}

	void cardinality() {
		auto item = pop();
		if (!item.isKind(ValueKind.Quote)) {
			toss("CARDINALITY expects a quote.");
		}
		push(Value(Number(cast(double)item.quote.quote.toks.length)));
	}

	void enquote() {
		push(Value(Quote(pop())));
	}
}

class VM {
	private RuntimeContainer rtc;
	private Lexer lex;
	private Stack stack, stack2;
	private Function[wstring] table;

	this(ref Lexer lex, ref RuntimeContainer rtc) {
		this.lex = lex;
		this.rtc = rtc;
		this.table = rtc.table();
		this.stack.content.reserve(512);
		this.stack2.content.reserve(512);
	}

	void run(ref Container[] toks) {
		ulong ip = 0;
		while (ip < toks.length) {
			auto kind = toks[ip].getKind();
			auto prim = toks[ip].prim;
			switch (kind) {
				case TokenKind.Quote:
					stack.push(Value(Quote(toks[ip].quote)));
					break;
				case TokenKind.Char:
					stack.push(Value(Char(prim)));
					break;
				case TokenKind.Number:
					stack.push(Value(Number(prim)));
					break;
				case TokenKind.Plus:
					stack.plus();
					break;
				case TokenKind.Minus:
					stack.minus();
					break;
				case TokenKind.Mult:
					stack.mult();
					break;
				case TokenKind.Div:
					stack.div();
					break;
				case TokenKind.Slash:
					stack.pop();
					break;
				case TokenKind.Dup:
					stack.dup();
					break;
				case TokenKind.Apply:
					if (!stack.curr().isKind(ValueKind.Quote)) {
						stack.toss("Expected a quote.");
					}
					auto item = stack.pop();
					run(item.quote.quote.toks);
					break;
				case TokenKind.Union:
					stack.uni();
					break;
				case TokenKind.Snatch:
					stack.snatch();
					break;
				case TokenKind.Display:
					stack.disp();
					break;
				case TokenKind.Identifier: {
					if (ip + 2 < toks.length) {
						if (toks[ip + 1].isKind(TokenKind.Assign)) {
							ip++;
							ip++;
							break;
						}
					}
					if (rtc.exists(prim.holder.content)) {
						run(table[prim.holder.content].quote.toks);
					}
					else {
						stack.toss("Identifier does not exist: " ~ to!string(prim.holder.content));
					}
					break;
				}
				case TokenKind.Equality:
					stack.equ();
					break;
				case TokenKind.NotEqu:
					stack.notequ();
					break;
				case TokenKind.Greater:
					stack.greater();
					break;
				case TokenKind.Less:
					stack.less();
					break;
				case TokenKind.GreaterEqu:
					stack.greaterEqu();
					break;
				case TokenKind.LessEqu:
					stack.lessEqu();
					break;
				case TokenKind.MovStack2:
					stack2.push(stack.pop());
					break;
				case TokenKind.TakeStack2:
					stack.push(stack2.pop());
					break;
				case TokenKind.Cardinality:
					stack.cardinality();
					break;
				case TokenKind.Enquote:
					stack.enquote();
					break;
				case TokenKind.Import:
					ip++;
					break;
				default: {
					import std.stdio;
					stderr.writeln("Not implemented!");
					break;
				}
			}
			ip++;
		}
	}

	ref Stack getStack() => this.stack;
	ref Stack getStack2() => this.stack2;
}
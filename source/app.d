import std.stdio;
import std.file;
import std.conv : to;
import lexer;
import pass;
import vm;

int main(string[] args) {
	if (args.length < 2) {
		stderr.writeln("Expected an argument.");
		stderr.writeln("Usage:");
		stderr.writeln("\t" ~ args[0] ~ " inputFile");
		return 1;
	}
	try {
		wstring file = to!wstring(readText(args[1])) ~ '\n';
		Lexer lex = new Lexer(file);
		lex.tokenize();
		RuntimeContainer rtc = new RuntimeContainer(lex.getToks());
		rtc.pass();
		VM rt = new VM(lex, rtc);
		rt.run(lex.getToks());
		foreach (item; rt.getStack2().content) {
			writeln(item);
		}
	}
	catch (Exception e) {
		stderr.writeln(e.message);
		return 2;
	}

	return 0;
}

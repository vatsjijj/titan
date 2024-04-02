import std.conv : to;
import std.stdio;
import std.file;
import lexer;
import error;
import pass;
import vm;

const string ver = "0.1.1";

void help(ref string[] args) {
	writeln("Usage:");
	writeln("\t", args[0], " [inputFile]");
	writeln("Flags:");
	writeln("\t--version, -v\tDisplays version information.");
	writeln("\t--help, -h\tDisplays this message.");
}

int main(string[] args) {
	if (args.length < 2) {
		stderr.writeln("Expected an argument.");
		stderr.flush();
		help(args);
		return 1;
	}
	if (args[1] == "--version" || args[1] == "-v") {
		writeln("Titan ", ver);
		return 0;
	}
	else if (args[1] == "--help" || args[1] == "-h") {
		help(args);
		return 0;
	}
	try {
		wstring file = to!wstring(readText(args[1])) ~ '\n';
		Lexer lex = new Lexer(file, args[1]);
		lex.tokenize();
		RuntimeContainer rtc = new RuntimeContainer(lex.getToks(), getcwd(), args[1]);
		rtc.pass();
		VM rt = new VM(lex, rtc, args[1]);
		rt.run(lex.getToks());
	}
	catch (Exception e) {
		stderr.writeln(e.message);
		stderr.flush();
		return 2;
	}

	return 0;
}

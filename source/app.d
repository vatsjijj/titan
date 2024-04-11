import std.conv : to;
import std.stdio;
import std.file;
import lexer;
import error;
import color;

const string ver = "0.1.0";

void help(ref string[] args) {
	RGB info = new RGB(INFO, Style.Bold);
	RGB explain = new RGB(0x55D34C);

	writeln(info, "Usage", RESET, ':');
	writeln("\t", args[0], explain, " [inputFile]", RESET);
	writeln(info, "Flags", RESET, ':');
	writeln(explain, "\t--version", RESET, ", ", explain, "-v", RESET, "\tDisplays version information.");
	writeln(explain, "\t--help", RESET, ", ", explain, "-h", RESET, "\tDisplays this message.");
}

int main(string[] args) {
	if (args.length < 2) {
		RGB error = new RGB(ERROR, Style.Bold);
		stderr.write(error, "Error", RESET, ": ");
		stderr.writeln("Expected an argument.");
		stderr.flush();
		help(args);
		return 1;
	}
	if (args[1] == "--version" || args[1] == "-v") {
		writeln("Titan-CD ", ver);
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
	}
	catch (Exception e) {
		RGB error = new RGB(ERROR, Style.Bold);
		stderr.writeln(error, "Error", RESET, ": ", e.message);
		stderr.flush();
		return 2;
	}

	return 0;
}

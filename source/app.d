import std.conv : to;
import std.stdio;
import std.file;
import std.datetime.stopwatch : benchmark, StopWatch;
import lexer;
import error;
import color;
import compiler;
import vm;
import serialize;

const string ver = "0.1.0";
const ubyte[5] magicNumber = cast(ubyte[5])"T2BC\n";

void help(ref string[] args) {
	RGB info = new RGB(INFO, Style.Bold);
	RGB explain = new RGB(0x55D34C);

	writeln(info, "Usage", RESET, ':');
	writeln("\t", args[0], explain, " [inputFile]", RESET);
	writeln(info, "Flags", RESET, ':');
	writeln(explain, "\t--version", RESET, ", ", explain, "-v", RESET, "\tDisplays version information.");
	writeln(explain, "\t--help", RESET, ", ", explain, "-h", RESET, "\tDisplays this message.");
}

void status(string msg) {
	RGB explain = new RGB(0x55D34C);
	writeln(explain, "   Status", RESET, ":\t ", msg);
}

void info(string msg) {
	RGB info = new RGB(INFO);
	writeln(info, "     Info", RESET, ":\t ", msg);
}

int main(string[] args) {
	string output = "out.t2bc";
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
		StopWatch sw = StopWatch();
		RGB fileCol = new RGB(INFO, Style.Underline);
		info("Performing build.");
		ubyte[] fin = [];
		sw.start();
		fin ~= magicNumber;
		status("Reading '" ~ fileCol.toString() ~ args[1] ~ RESET ~ "'...");
		wstring file = to!wstring(readText(args[1])) ~ '\n';
		Lexer lex = new Lexer(file, args[1]);
		status("Tokenizing...");
		lex.tokenize();
		Compiler c = new Compiler(lex);
		status("Populating constant pool...");
		c.fillPool();
		status("Emitting constant pool...");
		fin ~= c.getPool().emit();
		status("Compiling '" ~ fileCol.toString() ~ args[1] ~ RESET ~ "'...");
		c.compile();
		status("Emitting bytecode...");
		fin ~= c.getProgram().emit();
		status("Writing program to '" ~ fileCol.toString() ~ output ~ RESET ~ "'...");
		std.file.write(output, fin);
		sw.stop();
		status("Done!");
		info("Wrote " ~ to!string(fin.length) ~ " bytes to '" ~ fileCol.toString() ~ output ~ RESET ~ "'.");
		auto d = sw.peek();
		info("Compiled in " ~ d.toString() ~ ".");
	}
	catch (Exception e) {
		RGB error = new RGB(ERROR, Style.Bold);
		stderr.writeln(error, "Error", RESET, ": ", e.message);
		stderr.flush();
		return 2;
	}

	return 0;
}

module error;

import core.stdc.stdlib : exit;
import std.stdio;

struct TitanError {
	string filename;
	ulong line, col;
	string message;

	this(string filename) {
		this.filename = filename;
	}
	this(string filename, ulong line, ulong col, string message) {
		this.filename = filename;
		this.line = line;
		this.col = col;
		this.message = message;
	}

	void display(int status) {
		stderr.write("Error in ", filename, " at ", line, ":", col, ":\n\t");
		stderr.writeln(message);
		exit(status);
	}
}
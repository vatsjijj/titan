module error;

import core.stdc.stdlib : exit;
import std.stdio;
import color;

enum MessageKind {
	Fatal,
	Warn,
	Info,
}

struct TitanError {
	string filename;
	ulong line, col;
	string message;
	MessageKind kind;

	this(string filename) {
		this.filename = filename;
	}
	this(string filename, ulong line, ulong col, string message) {
		this.filename = filename;
		this.line = line;
		this.col = col;
		this.message = message;
	}

	RGB resolveKind() {
		switch (kind) {
			case MessageKind.Fatal: return new RGB(ERROR);
			case MessageKind.Warn: return new RGB(WARN);
			case MessageKind.Info: return new RGB(INFO);
			default: return new RGB(0x000000);
		}
	}
	RGB resolveKind(Style[] style...) {
		switch (kind) {
			case MessageKind.Fatal: return new RGB(ERROR, style);
			case MessageKind.Warn: return new RGB(WARN, style);
			case MessageKind.Info: return new RGB(INFO, style);
			default: return new RGB(0x000000, style);
		}
	}

	string resolveName() {
		switch (kind) {
			case MessageKind.Fatal: return "Error";
			case MessageKind.Warn: return "Warning";
			case MessageKind.Info: return "Info";
			default: return "Unknown";
		}
	}

	void display(int status = 0) {
		bool willExit = status != 0;
		RGB colorBold = resolveKind(Style.Bold);
		RGB fileColor = new RGB(INFO, Style.Underline);
		RGB info = new RGB(INFO);
		string name = resolveName();
		bool noColor = fileColor.getNoColor();

		stderr.write(colorBold, name, RESET, ' ');
		stderr.write("in '", fileColor, filename, RESET, "' at ");
		if (noColor) {
			stderr.write('(', line, ':', col, "):\n\t");
		}
		else {
			stderr.write(DIM, '(', RESET, info, line, RESET, DIM, ':', RESET, info, col, RESET, DIM, ')', RESET, ":\n\t");
		}
		stderr.writeln(message);

		if (willExit) {
			stderr.flush();
			exit(status);
		}
	}
}

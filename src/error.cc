#include "include/error.hh"
#include "include/color.hh"
#include <iostream>

const Titan::RGB fatalHeader   = Titan::RGB(255, 59, 59, {Titan::Style::BOLD});
const Titan::RGB warningHeader = Titan::RGB(255, 190, 59, {Titan::Style::BOLD});
const Titan::RGB infoHeader    = Titan::RGB(59, 203, 255, {Titan::Style::BOLD});
const Titan::RGB fileColor
	= Titan::RGB(59, 150, 255, {Titan::Style::BOLD, Titan::Style::UNDERLINE});

Titan::Error::Error(
	std::string msg,
	MessageKind kind,
	Holder* holder,
	std::shared_ptr<std::string> filename,
	std::shared_ptr<std::u16string> file
) {
	if (!holder) {
		throw "Holder cannot be NULL";
	}
	_msg      = msg;
	_filename = filename;
	_file     = file;
	_kind     = kind;
	_holder   = std::unique_ptr<Holder>(holder);
}

void Titan::Error::display(int code = 0) {
	bool willExit = false;
	switch (_kind) {
		case MessageKind::FATAL:
			willExit = true;
			ewrite("Error", fatalHeader);
			break;
		case MessageKind::WARNING:
			ewrite("Warning", warningHeader);
			break;
		case MessageKind::INFO:
			ewrite("Info", infoHeader);
			break;
		default:
			throw "Invalid message type.";
	}
	std::cerr << " in file '";
	ewrite(*_filename, fileColor);
	std::cerr << "' at " << DIM << '(' << RESET;
	ewrite(std::to_string(_holder->getLine()), fileColor);
	std::cerr << DIM << ':' << RESET;
	ewrite(std::to_string(_holder->getCol()), fileColor);
	std::cerr << DIM << ')' << RESET << ":\n\t";
	std::cerr << BOLD << _msg << RESET << '\n';

	if (willExit) exit(code);
}

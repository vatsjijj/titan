#include "include/color.hh"
#include <boost/locale.hpp>
#include <cstdlib>
#include <iostream>
#include <sstream>

bool Titan::checkEnv() {
	return std::getenv("NO_COLOR") && std::getenv("NO_COLOR")[0] != '\0';
}

Titan::RGB::RGB(uint8_t r, uint8_t g, uint8_t b) {
	_r       = r;
	_g       = g;
	_b       = b;
	_styles  = {Style::NONE};
	_noColor = checkEnv();
}

Titan::RGB::RGB(uint8_t r, uint8_t g, uint8_t b, std::vector<Style> styles) {
	_r       = r;
	_g       = g;
	_b       = b;
	_styles  = styles;
	_noColor = checkEnv();
}

std::string Titan::RGB::asString() {
	std::stringstream ss;
	ss << _emitStyles() << _emitColor();
	return ss.str();
}

bool Titan::RGB::getNoColor() {
	return _noColor;
}

std::string Titan::RGB::_emitStyle(Titan::Style& style) {
	switch (style) {
		case Titan::Style::NONE:
			return "\x1b[0m";
		case Titan::Style::BOLD:
			return "\x1b[1m";
		case Titan::Style::DIM:
			return "\x1b[2m";
		case Titan::Style::ITALIC:
			return "\x1b[3m";
		case Titan::Style::UNDERLINE:
			return "\x1b[4m";
	}
	return "\x1b[0m";
}

std::string Titan::RGB::_emitStyles() {
	if (_styles.size() == 0) {
		return "";
	}
	else if (_styles.size() == 1) {
		return _emitStyle(_styles.at(0));
	}
	std::stringstream ss;
	for (auto& style : _styles) {
		ss << _emitStyle(style);
	}
	return ss.str();
}

std::string Titan::RGB::_emitColor() {
	std::stringstream ss;
	ss << "\x1b[38;2;";
	ss << std::to_string(_r) << ';';
	ss << std::to_string(_g) << ';';
	ss << std::to_string(_b) << 'm';
	return ss.str();
}

void Titan::write(std::string msg, RGB color) {
	if (color.getNoColor()) {
		std::cout << msg;
		return;
	}
	std::cout << color.asString() << msg << RESET;
}

void Titan::write(std::u16string msg, RGB color) {
	std::string str8 = boost::locale::conv::utf_to_utf<char>(msg);
	if (color.getNoColor()) {
		std::cout << str8;
		return;
	}
	std::cout << color.asString() << str8 << RESET;
}

void Titan::writeLine(std::string msg, RGB color) {
	write(msg, color);
	std::cout << '\n';
}

void Titan::writeLine(std::u16string msg, RGB color) {
	write(msg, color);
	std::cout << '\n';
}

void Titan::ewrite(std::string msg, RGB color) {
	if (color.getNoColor()) {
		std::cerr << msg;
		return;
	}
	std::cerr << color.asString() << msg << RESET;
}

void Titan::ewrite(std::u16string msg, RGB color) {
	std::string str8 = boost::locale::conv::utf_to_utf<char>(msg);
	if (color.getNoColor()) {
		std::cerr << str8;
		return;
	}
	std::cerr << color.asString() << str8 << RESET;
}

void Titan::ewriteLine(std::string msg, RGB color) {
	ewrite(msg, color);
	std::cerr << '\n';
}

void Titan::ewriteLine(std::u16string msg, RGB color) {
	ewrite(msg, color);
	std::cerr << '\n';
}

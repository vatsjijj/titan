#pragma once

#include <cstdint>
#include <string>
#include <vector>

namespace Titan {
	const std::string RESET     = "\x1b[0m";
	const std::string BOLD      = "\x1b[1m";
	const std::string DIM       = "\x1b[2m";
	const std::string ITALIC    = "\x1b[3m";
	const std::string UNDERLINE = "\x1b[4m";

	enum class Style {
		UNDERLINE,
		ITALIC,
		BOLD,
		DIM,
		NONE,
	};

	bool checkEnv();

	class RGB {
	 public:
		RGB(uint8_t r, uint8_t g, uint8_t b);
		RGB(uint8_t r, uint8_t g, uint8_t b, std::vector<Style> styles);

		std::string asString();

		bool getNoColor();

	 private:
		uint8_t _r, _g, _b;
		std::vector<Style> _styles;
		bool _noColor;

		std::string _emitStyle(Style& style);

		std::string _emitStyles();

		std::string _emitColor();
	};

	void write(std::string msg, RGB color);
	void write(std::u16string msg, RGB color);

	void writeLine(std::string msg, RGB color);
	void writeLine(std::u16string msg, RGB color);

	void ewrite(std::string msg, RGB color);
	void ewrite(std::u16string msg, RGB color);

	void ewriteLine(std::string msg, RGB color);
	void ewriteLine(std::u16string msg, RGB color);
} // namespace Titan

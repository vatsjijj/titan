#pragma once

#include <string>
#include <cstdint>

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
	};

	class RGB {
	public:
		RGB(uint8_t r, uint8_t g, uint8_t b);
	private:
		uint8_t r, g, b;
	};
}
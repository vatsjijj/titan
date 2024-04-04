#include <iostream>
#include <cstring>
#include "include/file.hh"
#include "include/common.hh"
#include "include/color.hh"

void help(const char* arg) {
	Titan::ewriteLine("Usage:", Titan::RGB(0, 255, 255, Titan::Style::BOLD));
	std::cout << '\t' << arg << " [file]\n\t";
	std::cout << arg << " [flag]\n\n";

	Titan::ewriteLine("Flags:", Titan::RGB(0, 255, 255, Titan::Style::BOLD));
	std::cout << "\t--help, -h\tDisplays this message.\n\t";
	std::cout << "--version, -v\tDisplays version information." << std::endl;
}

int main(int argc, const char* argv[]) {
	if (argc < 2) {
		Titan::ewrite("Error: ", Titan::RGB(255, 0, 0, Titan::Style::BOLD));
		std::cerr << "Expected an argument.\n";
		help(argv[0]);
		return 1;
	}
	else if (std::strcmp(argv[1], "--help") == 0 || std::strcmp(argv[1], "-h") == 0) {
		help(argv[0]);
		return 0;
	}
	else if (std::strcmp(argv[1], "--version") == 0 || std::strcmp(argv[1], "-v") == 0) {
		std::cout << "Titan-C++ " << TITAN_VERSION << std::endl;
		return 0;
	}

	auto file = Titan::readFile(argv[1]);

	return 0;
}

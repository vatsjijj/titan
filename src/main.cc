#include <iostream>
#include "include/file.hh"

int main(int argc, const char* argv[]) {
	if (argc < 2) {
		std::cerr << "Expected an argument.\n";
		std::cerr << "Usage:\n   ";
		std::cerr << argv[0] << " file" << std::endl;
		return 1;
	}

	auto file = Titan::readFile(argv[1]);

	return 0;
}
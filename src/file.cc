#include "include/file.hh"
#include <boost/locale.hpp>
#include <fstream>
#include <sstream>

std::u16string Titan::readFile(std::string filename) {
	std::ifstream f(filename);

	if (!f.is_open()) {
		throw "Could not open " + filename;
	}

	std::stringstream ss;
	ss << f.rdbuf();
	std::string str8 = ss.str();

	std::u16string content = boost::locale::conv::utf_to_utf<char16_t>(str8);

	return content;
}

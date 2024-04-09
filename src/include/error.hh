#pragma once

#include "lexer.hh"
#include <memory>
#include <string>

namespace Titan {
	enum class MessageKind {
		FATAL,
		WARNING,
		INFO,
	};

	class Error {
	 public:
		Error(
			std::string msg,
			MessageKind kind,
			Holder* holder,
			std::shared_ptr<std::string> filename,
			std::shared_ptr<std::u16string> file
		);

		void display(int code);

	 private:
		std::shared_ptr<std::string> _filename;
		std::string _msg;
		std::shared_ptr<std::u16string> _file;
		std::unique_ptr<Holder> _holder;
		MessageKind _kind;
	};
} // namespace Titan

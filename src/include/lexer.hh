#pragma once

#include <cstddef>
#include <memory>
#include <string>
#include <vector>

namespace Titan {
	enum class TokenKind {
		IDENTIFIER,
		NUMBER,
		CHAR,
		QUOTE,
		PLUS,
		MINUS,
		TIMES,
		DIVIDE,
		MODULO,
		UNION,
		APPLY,
		ENQUOTE,
		DUP,
		EQUAL,
		DISPLAY,
		ASSIGN,
		SLASH,
		SNATCH,
		NOTEQUAL,
		LESS,
		GREATER,
		LESSEQUAL,
		GREATEREQUAL,
		MOVSTACK2,
		TAKESTACK2,
		CARDINALITY,
		USING,
		ABSOLUTE,
	};

	enum class ValueKind {
		QUOTE,
		NUMBER,
		CHAR,
		IDENTIFIER,
	};

	class Holder {
	 public:
		Holder(TokenKind kind, std::u16string content, std::size_t line, std::size_t col);

		bool isKind(TokenKind kind);

		TokenKind& getKind();

		std::u16string& getContent();

		std::size_t& getLine();

		std::size_t& getCol();

		std::size_t& getLen();

	 private:
		TokenKind _kind;
		std::u16string _content;
		std::size_t _line, _col, _len;
	};

	class Primitive : public Holder {
	 public:
		Primitive(TokenKind kind, std::u16string content, std::size_t line, std::size_t col);

		double& asDouble();

		char16_t& asChar();

	 private:
		union {
			double d;
			char16_t c;
		} _as;
	};

	class Quote : public Holder {
	 public:
		Quote(std::size_t line, std::size_t col);

		void append(Holder& holder);

		std::vector<Holder>& getToks();

	 private:
		std::vector<Holder> _toks;
	};

	union Value {
		bool _DUMMY;

		Value(Quote& quote);
		Value(Primitive& prim);

		~Value();

		std::unique_ptr<Quote> _quote;
		std::unique_ptr<Primitive> _prim;
	};

	class Container {
	 public:
		Container(Quote& quote);
		Container(Primitive& prim);

		Quote& asQuote();

		Primitive& asPrim();

		bool isKind(ValueKind kind);

		ValueKind& getKind();

	 private:
		ValueKind _kind;
		Value _as;
	};

	class Lexer {
	 public:
		Lexer(std::u16string& file, std::string& filename);

		void tokenize();

		std::u16string& getFile();

		std::string& getFileName();

		std::vector<Container>& getToks();

	 private:
		std::u16string _file;
		std::string _filename;
		std::vector<Container> _toks;
	};
} // namespace Titan

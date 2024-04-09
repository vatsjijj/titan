#include "include/lexer.hh"

Titan::Holder::Holder(TokenKind kind, std::u16string content, std::size_t line, std::size_t col) {
	_kind    = kind;
	_content = content;
	_line    = line;
	_col     = col;
	_len     = content.length();
}

Titan::Primitive::Primitive(
	TokenKind kind,
	std::u16string content,
	std::size_t line,
	std::size_t col
)
	 : Holder(kind, content, line, col) {}

Titan::Quote::Quote(std::size_t line, std::size_t col) : Holder(TokenKind::QUOTE, u"", line, col) {}

Titan::Value::Value(Quote& quote) {
	_DUMMY = false;
	_quote = std::unique_ptr<Quote>(&quote);
}

Titan::Value::Value(Primitive& prim) {
	_DUMMY = true;
	_prim  = std::unique_ptr<Primitive>(&prim);
}

Titan::Container::Container(Quote& quote) : _as(quote) {
	_kind = ValueKind::QUOTE;
}

Titan::Container::Container(Primitive& prim) : _as(prim) {
	if (prim.getKind() == TokenKind::CHAR) {
		_kind = ValueKind::CHAR;
	}
	else if (prim.getKind() == TokenKind::NUMBER) {
		_kind = ValueKind::NUMBER;
	}
	else {
		_kind = ValueKind::IDENTIFIER;
	}
}

Titan::Lexer::Lexer(std::u16string& file, std::string& filename) {
	_file     = file;
	_filename = filename;
}

Titan::Value::~Value() {}

bool Titan::Holder::isKind(TokenKind kind) {
	return _kind == kind;
}

Titan::TokenKind& Titan::Holder::getKind() {
	return _kind;
}

std::u16string& Titan::Holder::getContent() {
	return _content;
}

std::size_t& Titan::Holder::getLine() {
	return _line;
}

std::size_t& Titan::Holder::getCol() {
	return _col;
}

std::size_t& Titan::Holder::getLen() {
	return _len;
}

double& Titan::Primitive::asDouble() {
	return _as.d;
}

char16_t& Titan::Primitive::asChar() {
	return _as.c;
}

void Titan::Quote::append(Holder& holder) {
	_toks.push_back(holder);
}

std::vector<Titan::Holder>& Titan::Quote::getToks() {
	return _toks;
}

Titan::Quote& Titan::Container::asQuote() {
	if (_kind != ValueKind::QUOTE) {
		throw "Kind is not QUOTE";
	}
	return *_as._quote;
}

Titan::Primitive& Titan::Container::asPrim() {
	if (_kind != ValueKind::QUOTE) {
		return *_as._prim;
	}
	throw "Kind is not PRIM";
}

bool Titan::Container::isKind(ValueKind kind) {
	return _kind == kind;
}

Titan::ValueKind& Titan::Container::getKind() {
	return _kind;
}

void Titan::Lexer::tokenize() {}

std::u16string& Titan::Lexer::getFile() {
	return _file;
}

std::string& Titan::Lexer::getFileName() {
	return _filename;
}

std::vector<Titan::Container>& Titan::Lexer::getToks() {
	return _toks;
}

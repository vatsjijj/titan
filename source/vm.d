module vm;

enum OpCode : ubyte {
	TableBegin,
	TableEnd,
	EntryD,
	EntryW,
	EntryQ,
	LenB,
	LenS,
	LenI,
	LoadB,
	LoadS,
	LoadI,
	CallB,
	CallS,
	CallI,
	Add,
	Display,
}

module dbg;

import std.conv : to;
import std.bitmanip;
import std.stdio;
import vm : OpCode;
import serialize;

private ConstantPool inhaleConstantPool(ref ulong idx, ref ubyte[] program) {
	ubyte[] res;
	if (program[idx] != OpCode.TableBegin) {
		throw new Exception("Expected TableBegin at " ~ to!string(idx) ~ '.');
	}
	Length len;
	idx++;
	if (program[idx] == OpCode.LenB) {
		idx++;
		len = new Length(program[idx++]);
	}
	else if (program[idx] == OpCode.LenS) {
		idx++;
		ubyte[ushort.sizeof] b = program[idx..(idx + ushort.sizeof)];
		ushort s = littleEndianToNative!(ushort, ushort.sizeof)(b);
		idx += ushort.sizeof;
		len = new Length(s);
	}
	else if (program[idx] == OpCode.LenI) {
		idx++;
		ubyte[uint.sizeof] b = program[idx..(idx + uint.sizeof)];
		uint i = littleEndianToNative!(uint, uint.sizeof)(b);
		idx += uint.sizeof;
		len = new Length(i);
	}
	else {
		throw new Exception("Malformed bytecode at " ~ to!string(idx) ~ '.');
	}
	ulong raw = len.getRawLength();
	ulong curr = 0uL;
	if (raw == curr) return new ConstantPool();
	while (curr < raw) {
		if (program[idx] == OpCode.EntryD) {
			res ~= program[idx++];
			foreach (_; 0..double.sizeof) {
				res ~= program[idx++];
			}
			curr++;
		}
		else if (program[idx] == OpCode.EntryW) {
			res ~= program[idx++];
			foreach (_; 0..wchar.sizeof) {
				res ~= program[idx++];
			}
			curr++;
		}
		else if (program[idx] == OpCode.EntryQ) {
			throw new Exception("Quotes are not supported.");
		}
	}
	if (program[idx] != OpCode.TableEnd) {
		throw new Exception("Malformed bytecode at " ~ to!string(idx) ~ '.');
	}
	idx++;
	return cast(ConstantPool)ConstantPool.deserialize(res);
}

private ubyte[] inhaleProgram(ref ulong idx, ref ubyte[] program) {
	if (program[idx] != OpCode.TableBegin) {
		throw new Exception("Malformed bytecode at " ~ to!string(idx) ~ '.');
	}
	idx++;
	Length len;
	if (program[idx] == OpCode.LenB) {
		idx++;
		len = new Length(program[idx++]);
	}
	else if (program[idx] == OpCode.LenS) {
		idx++;
		ubyte[ushort.sizeof] b = program[idx..(idx + ushort.sizeof)];
		ushort s = littleEndianToNative!(ushort, ushort.sizeof)(b);
		idx += ushort.sizeof;
		len = new Length(s);
	}
	else if (program[idx] == OpCode.LenI) {
		idx++;
		ubyte[uint.sizeof] b = program[idx..(idx + uint.sizeof)];
		uint i = littleEndianToNative!(uint, uint.sizeof)(b);
		idx += uint.sizeof;
		len = new Length(i);
	}
	else {
		throw new Exception("Malformed bytecode at " ~ to!string(idx) ~ '.');
	}
	ulong raw = len.getRawLength();
	ubyte[] res;
	foreach (_; 0..raw) {
		res ~= program[idx++];
	}
	if (program[idx] != OpCode.TableEnd) {
		throw new Exception("Malformed bytecode at " ~ to!string(idx) ~ '.');
	}
	return res;
}

void dasm(ref ubyte[] program) {
	ubyte[5] number = program[0..5];
	if (number != cast(ubyte[5])"T2BC\n") {
		throw new Exception("Malformed bytecode or invalid format.");
	}
	ulong idx = 5;
	ConstantPool pool = inhaleConstantPool(idx, program);
	ubyte[] p = inhaleProgram(idx, program);

	writeln("Constant pool length:\t", pool.pullLength(), '\n');

	ulong i = 0;
	while (i < p.length) {
		switch (p[i]) {
			case OpCode.LoadB:
				i++;
				writeln("   LODB:\t", p[i]);
				break;
			case OpCode.Add:
				writeln("    ADD");
				break;
			case OpCode.Display:
				writeln("   DISP");
				break;
			default:
				writeln("   UNDF:\t", p[i]);
				break;
		}
		i++;
	}
}

module serialize;

import std.bitmanip;
import vm : OpCode;

interface Serializable {
	ubyte[n] serialize(ulong n)();
	static Serializable deserialize(ulong n)(ref ubyte[n] data);
}

interface DynSerializable {
	ubyte[] serialize();
	static DynSerializable deserialize(ref ubyte[] data);
}

interface Emittable {
	ubyte[] emit();
}

final class Length : DynSerializable, Emittable {
	private ulong len;

	this() {
		this.len = ulong.init;
	}
	this(ulong len) {
		this.len = len;
	}

	ulong getRawLength() {
		return this.len;
	}

	ubyte[] serialize() {
		if (len <= ubyte.max) {
			return [cast(ubyte)len];
		}
		else if (len > ubyte.max && len <= ushort.max) {
			ubyte[ushort.sizeof] b = nativeToLittleEndian(cast(ushort)len);
			ubyte[] res;
			foreach (i; 0..ushort.sizeof) res ~= b[i];
			return res;
		}
		else if (len > ushort.max && len <= uint.max) {
			ubyte[uint.sizeof] b = nativeToLittleEndian(cast(uint)len);
			ubyte[] res;
			foreach (i; 0..uint.sizeof) res ~= b[i];
			return res;
		}
		throw new Exception("How did you get here?");
	}

	static DynSerializable deserialize(ref ubyte[] data) {
		throw new Exception("Not implemented.");
	}

	ubyte[] emit() {
		if (len <= ubyte.max) {
			return [OpCode.LenB, cast(ubyte)len];
		}
		else if (len > ubyte.max && len <= ushort.max) {
			ubyte[] tmp = [OpCode.LenS];
			ubyte[ushort.sizeof] b = nativeToLittleEndian(cast(ushort)len);
			return tmp ~ b;
		}
		else if (len > ushort.max && len <= uint.max) {
			ubyte[] tmp = [OpCode.LenI];
			ubyte[uint.sizeof] b = nativeToLittleEndian(cast(uint)len);
			return tmp ~ b;
		}
		throw new Exception("How did you get here?");
	}

	ubyte[] emitl() {
		auto s = serialize();
		if (s.length == 1) {
			return OpCode.LoadB ~ s;
		}
		else if (s.length == ushort.sizeof) {
			return OpCode.LoadS ~ s;
		}
		else if (s.length == uint.sizeof) {
			return OpCode.LoadI ~ s;
		}
		throw new Exception("How did you get here?");
	}
}

final class Double : Serializable, Emittable {
	private double d;

	this() {
		this.d = double.init;
	}
	this(double d) {
		this.d = d;
	}

	double getValue() {
		return this.d;
	}

	ubyte[double.sizeof] serialize() {
		ubyte[double.sizeof] b = nativeToLittleEndian(d);
		return b;
	}

	static Serializable deserialize(ref ubyte[double.sizeof] data) {
		double val = littleEndianToNative!(double, double.sizeof)(data);
		return new Double(val);
	}

	ubyte[] emit() {
		ubyte[] res = [OpCode.EntryD];
		auto b = serialize();
		return res ~ b;
	}
}

final class WideChar : Serializable, Emittable {
	private wchar c;

	this() {
		this.c = wchar.init;
	}
	this(wchar c) {
		this.c = c;
	}

	wchar getValue() {
		return this.c;
	}

	ubyte[wchar.sizeof] serialize() {
		ubyte[wchar.sizeof] b = nativeToLittleEndian(c);
		return b;
	}

	static Serializable deserialize(ref ubyte[wchar.sizeof] data) {
		wchar val = littleEndianToNative!(wchar, wchar.sizeof)(data);
		return new WideChar(val);
	}

	ubyte[] emit() {
		ubyte[] res = [OpCode.EntryW];
		auto b = serialize();
		return res ~ b;
	}
}

final class ConstantPool : DynSerializable, Emittable {
	private Emittable[] pool;

	this() {
		this.pool = [];
	}
	this(ref Emittable[] pool) {
		this.pool = pool;
	}

	Length add(ref Emittable item) {
		Length len = new Length(pool.length);
		this.pool ~= item;
		return len;
	}
	Length add(double d) {
		Length len = new Length(pool.length);
		this.pool ~= new Double(d);
		return len;
	}
	Length add(wchar c) {
		Length len = new Length(pool.length);
		this.pool ~= new WideChar(c);
		return len;
	}

	ref Emittable at(ulong idx) {
		if (idx >= pool.length) {
			throw new Exception("Invalid index.");
		}
		return pool[idx];
	}

	ubyte[] serialize() {
		ubyte[] res;
		foreach (c; pool) {
			res ~= c.emit();
		}
		return res;
	}

	static DynSerializable deserialize(ref ubyte[] data) {
		ConstantPool res = new ConstantPool();
		ulong idx = 0;
		while (idx < data.length) {
			if (data[idx] == OpCode.EntryD) {
				idx++;
				ubyte[double.sizeof] b = data[idx..(idx + double.sizeof)];
				Emittable d = cast(Double)Double.deserialize(b);
				idx += double.sizeof - 1;
				res.add(d);
			}
			else if (data[idx] == OpCode.EntryW) {
				idx++;
				ubyte[wchar.sizeof] b = data[idx..(idx + wchar.sizeof)];
				Emittable w = cast(WideChar)WideChar.deserialize(b);
				idx += wchar.sizeof - 1;
				res.add(w);
			}
			else {
				import std.conv : to;
				throw new Exception("Unsupported or malformed entry. " ~ to!string(data[idx]));
			}
			idx++;
		}
		return res;
	}

	ubyte[] emit() {
		Length len = new Length(pool.length);
		ubyte[] res = [OpCode.TableBegin];
		res ~= len.emit();
		res ~= serialize();
		return res ~ OpCode.TableEnd;
	}
}

final class Program : DynSerializable, Emittable {
	private ubyte[] program;

	this() {
		this.program = [];
	}
	this(ref ubyte[] program) {
		this.program = program;
	}

	ubyte[] serialize() {
		return this.program;
	}

	static DynSerializable deserialize(ref ubyte[] data) {
		return new Program(data);
	}

	ubyte[] emit() {
		Length len = new Length(program.length);
		ubyte[] res = [OpCode.TableBegin];
		res ~= len.emit();
		res ~= serialize();
		return res ~ OpCode.TableEnd;
	}
}

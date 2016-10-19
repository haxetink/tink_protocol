package tink.protocol.rethinkdb;

import haxe.Int64;

class Frame {
	public var type:FrameType;
	public var pos:Int64;
	public var opt:String;
}

@:enum
abstract FrameType(Int) from Int {
	var POS = 1;
	var OPT = 2;
}
package websocket;

import haxe.io.Bytes;

class Frame {
	public var fin:Bool;
	public var opcode:Opcode;
	public var payload:Bytes;
	
	public function new(fin, opcode, payload) {
		this.fin = fin;
		this.opcode = opcode;
		this.payload = payload;
	}
}

@:enum
abstract Opcode(Int) from Int {
	var Continuation = 0x0;
	var Text = 0x1;
	var Binary = 0x2;
	var ConnectionClose = 0x8;
	var Ping = 0x9;
	var Pong = 0xa;
}
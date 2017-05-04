package tink.protocol.websocket;

import haxe.io.Bytes;

abstract MaskingKey(Chunk) to Chunk {
	public function new(a, b, c, d) {
		var bytes = Bytes.alloc(4);
		bytes.set(0, a);
		bytes.set(1, b);
		bytes.set(2, c);
		bytes.set(3, d);
		this = bytes;
	}
	
	public static function random() {
		return new MaskingKey(Std.random(256), Std.random(256), Std.random(256), Std.random(256));
	}
}
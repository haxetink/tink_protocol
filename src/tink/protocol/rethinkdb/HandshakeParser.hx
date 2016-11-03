package tink.protocol.rethinkdb;

import haxe.io.Bytes;
import tink.io.StreamParser;

class HandshakeParser extends Splitter {
	public function new() {
		var delim = Bytes.alloc(1);
		delim.set(0, 0);
		super(delim);
	}
}
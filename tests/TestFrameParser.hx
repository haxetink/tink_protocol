package;

import buddy.*;
import haxe.io.Bytes;
import tink.io.Source;
import websocket.FrameParser;

using buddy.Should;

class TestFrameParser extends BuddySuite {
	public function new() {
		describe("Frame Parser", {
			it("should parse a basic frame", function(done) {
				var frame:Source = arrayToBytes([129, 131, 61, 84, 35, 6, 112, 16, 109]);
				frame.parseStream(new FrameParser()).forEach(function(frame) {
					frame.fin.should.be(true);
					frame.opcode.should.be(1);
					frame.payload.toString().should.be('MDN');
					done();
					return false;
				});
			});
		});
	}
	
	function arrayToBytes(a:Array<Int>):Bytes {
		var bytes = Bytes.alloc(a.length);
		for(i in 0...a.length) bytes.set(i, a[i]);
		return bytes;
	}
}
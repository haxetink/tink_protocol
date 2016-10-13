package;

import buddy.*;
import haxe.io.Bytes;
import tink.io.Source;
import tink.protocol.websocket.Parser;
import tink.protocol.websocket.Frame;

using buddy.Should;

class TestFrameParser extends BuddySuite {
	public function new() {
		describe("Frame Parser", {
			it("should parse a basic frame", function(done) {
				var source:Source = arrayToBytes([129, 131, 61, 84, 35, 6, 112, 16, 109]);
				source.parseStream(new Parser()).forEach(function(bytes) {
					bytes.toHex().should.be('81833d54230670106d');
					var frame:Frame = bytes;
					frame.fin.should.be(true);
					frame.opcode.should.be(1);
					frame.mask.should.be(true);
					frame.maskingKey.toHex().should.be('3d542306');
					frame.payload.toHex().should.be('70106d');
					Frame.decode(frame.payload, frame.maskingKey).toString().should.be('MDN');
					return true;
				}).handle(function(_) done());
			});
			it("should parse consecutive frames", function(done) {
				var frame = [129, 131, 61, 84, 35, 6, 112, 16, 109];
				var source:Source = arrayToBytes(frame.concat(frame).concat(frame));
				source.parseStream(new Parser()).forEach(function(bytes) {
					bytes.toHex().should.be('81833d54230670106d');
					var frame:Frame = bytes;
					frame.fin.should.be(true);
					frame.opcode.should.be(1);
					frame.mask.should.be(true);
					frame.maskingKey.toHex().should.be('3d542306');
					frame.payload.toHex().should.be('70106d');
					Frame.decode(frame.payload, frame.maskingKey).toString().should.be('MDN');
					return true;
				}).handle(function(_) done());
			});
		});
	}
	
	function arrayToBytes(a:Array<Int>):Bytes {
		var bytes = Bytes.alloc(a.length);
		for(i in 0...a.length) bytes.set(i, a[i]);
		return bytes;
	}
}
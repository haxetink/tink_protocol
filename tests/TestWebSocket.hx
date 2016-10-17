package;

import buddy.*;
import haxe.io.Bytes;
import tink.io.Source;
import tink.tcp.Connection;
import tink.url.Host;
import tink.protocol.websocket.Client;
import tink.protocol.websocket.Frame;
import tink.protocol.websocket.Parser;

using buddy.Should;

class TestWebSocket extends BuddySuite {
	public function new() {
		describe("WebSocket", {
			describe("Parser", {
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
			
			describe("Client", {
				it("should work with the echo server", function(done) {
					var host = 'echo.websocket.org';
					var connection = Connection.establish({host: host, port: 80});
					var ws = new Client(connection, 'http://$host');
					
					var c = 0;
					var n = 7;
					var sender = Client.sender();
					ws.connect(sender).forEach(function(message) {
						switch message {
							case Text(v): v.should.be('payload' + ++c);
							default: fail('Unexpected message');
						}
						if(c == n) done();
						return c < n;
					});
					
					for(i in 0...n) sender.send(Text('payload' + (i + 1)));
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
package;

import haxe.io.Bytes;
import tink.tcp.Connection;
import tink.tcp.Server;
import tink.url.Host;
import tink.streams.Stream;
import tink.streams.Accumulator;
// import tink.protocol.websocket.Requester;
// import tink.protocol.websocket.Responder;
import tink.protocol.websocket.Message;
import tink.protocol.websocket.Frame;
import tink.protocol.websocket.Parser;
import tink.protocol.websocket.MaskingKey;
import tink.Chunk;

using tink.io.Source;

@:asserts
class TestWebSocket {
	public function new() {
		// describe("WebSocket", {
			
		// 	describe("Requester", {
		// 		it("should work with the echo server", function(done) {
		// 			var host = 'echo.websocket.org';
		// 			var connection = Connection.establish({host: host, port: 80});
		// 			var ws = new Requester(connection, 'http://$host');
					
		// 			var c = 0;
		// 			var n = 7;
		// 			var sender = new Accumulator();
		// 			ws.connect(sender).forEach(function(bytes) {
		// 				switch Frame.toMessage([Frame.fromBytes(bytes)]) {
		// 					case Some(Text(v)): v.should.be('payload' + ++c);
		// 					default: fail('Unexpected message');
		// 				}
		// 				if(c == n) done();
		// 				return c < n;
		// 			});
					
		// 			var key = Bytes.alloc(4);
		// 			for(i in 0...n) {
		// 				var frame = Frame.fromMessage(Text('payload' + (i + 1)));
		// 				frame.maskWith(key);
		// 				sender.yield(Data(frame.toBytes()));
		// 			}
		// 		});
		// 	});
			
		// 	describe("Responder", {
		// 		it("should work with the Requester", function(done) {
		// 			Server.bind(18088).handle(function(o) switch o {
		// 				case Success(server):
		// 					server.connected.handle(function(connection) {
		// 						var c = new Responder(connection);
		// 						var sender = new Accumulator();
		// 						c.connect(sender).forEach(function(bytes) {
		// 							// send back an identical but unmasked frame
		// 							var frame:Frame = bytes;
		// 							frame.unmask();
		// 							sender.yield(Data(frame.toBytes()));
		// 							return true;
		// 						});
		// 					});
							
		// 					var ws = new Requester(Connection.establish(18088), 'http://localhost');

		// 					var c = 0;
		// 					var n = 7;
		// 					var sender = new Accumulator();
		// 					ws.connect(sender).forEach(function(bytes) {
		// 						switch Frame.toMessage([Frame.fromBytes(bytes)]) {
		// 							case Some(Text(v)): v.should.be('payload' + ++c);
		// 							default: fail('Unexpected message');
		// 						}
		// 						if(c == n) done();
		// 						return c < n;
		// 					});
							
		// 					var key = Bytes.alloc(4);
		// 					for(i in 0...n) {
		// 						var frame = Frame.fromMessage(Text('payload' + (i + 1)));
		// 						frame.maskWith(key);
		// 						sender.yield(Data(frame.toBytes()));
		// 					}
							
		// 				case Failure(f): fail(f);
		// 			});
		// 		});
		// 	});
		// });
		
	}
	
	@:variant((this.arrayToBytes([129, 131, 61]):tink.io.Source.IdealSource).append(this.arrayToBytes([84, 35, 6, 112, 16, 109])), '81833d54230670106d', '3d542306', '70106d', 'MDN')
	@:variant(this.arrayToBytes([129, 131, 61, 84, 35, 6, 112, 16, 109]), '81833d54230670106d', '3d542306', '70106d', 'MDN')
	@:variant(tink.Chunk.ofHex('818823fb87c8539afea44c9ae3f9'), '818823fb87c8539afea44c9ae3f9', '23fb87c8', '539afea44c9ae3f9', 'payload1')
	public function parseSingleFrame(source:IdealSource, whole:String, key:String, masked:String, unmasked:String) {
		source.parseStream(new Parser()).forEach(function(chunk:Chunk) {
			var frame:Frame = chunk;
			asserts.assert(chunk.toBytes().toHex() == whole);
			asserts.assert(frame.fin == true);
			asserts.assert(frame.opcode == 1);
			asserts.assert(frame.mask == true);
			asserts.assert(frame.maskingKey.toHex() == key);
			asserts.assert(frame.maskedPayload.toHex() == masked);
			asserts.assert(frame.unmaskedPayload.toString() == unmasked);
			return Resume;
		}).handle(function(o) {
			asserts.assert(o == Depleted);
			asserts.done();
		});
		return asserts;
	}
	
	public function parseConsecutiveFrame() {
		var frame = [129, 131, 61, 84, 35, 6, 112, 16, 109];
		var source:IdealSource = arrayToBytes(frame.concat(frame).concat(frame));
		var num = 0;
		source.parseStream(new Parser()).forEach(function(chunk:Chunk) {
			asserts.assert(chunk.toBytes().toHex() == '81833d54230670106d');
			var frame:Frame = chunk;
			asserts.assert(frame.fin == true);
			asserts.assert(frame.opcode == 1);
			asserts.assert(frame.mask == true);
			asserts.assert(frame.maskingKey.toHex() == '3d542306');
			asserts.assert(frame.maskedPayload.toHex() == '70106d');
			asserts.assert(frame.unmaskedPayload.toString() == 'MDN');
			num++;
			return Resume;
		}).handle(function(o) {
			asserts.assert(o == Depleted);
			asserts.assert(num == 3);
			asserts.done();
		});
		return asserts;
	}
	
	@:include
	public function echo() {
		var host = 'http://echo.websocket.org';
		var c = 0;
		var n = 7;
		var sender = new Accumulator();
		var handler = tink.protocol.websocket.Acceptor.wrap(host, function(stream) {
			stream
				.map(function(chunk:Chunk):Frame return chunk)
				.regroup(MessageRegrouper.get())
				.forEach(function(message:Message) {
					switch message {
						case Text(v): asserts.assert(v == 'payload' + ++c);
						default: asserts.fail('Unexpected message');
					}
					if(c == n) asserts.done();
					return c < n ? Resume : Finish;
				});
			
			return sender;
		});
		var connection = tink.tcp.nodejs.NodejsConnector.connect({host: host, port: 80}, handler);
		// var connection = Connection.establish({host: host, port: 80});
		// var ws = new Requester(connection, 'http://$host');
		
		for(i in 0...n) {
			var frame = Frame.ofMessage(Text('payload' + (i + 1)), MaskingKey.random());
			var chunk = frame.toChunk();
			sender.yield(Data(chunk));
		}
		return asserts;
	}
	
	function arrayToBytes(a:Array<Int>):Chunk {
		var bytes = Bytes.alloc(a.length);
		for(i in 0...a.length) bytes.set(i, a[i]);
		return bytes;
	}
}
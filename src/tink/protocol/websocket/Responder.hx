package tink.protocol.websocket;

import haxe.io.Bytes;
import tink.streams.RealStream;
import tink.protocol.Protocol;
import tink.Chunk;

using tink.io.Sink;
using tink.io.Source;
using tink.CoreApi;

class Responder implements Protocol<Chunk, Chunk> {
	
	var source:RealSource;
	var sink:RealSink;
	
	public function new(source, sink) {
		this.source = source;
		this.sink = sink;
	}
	
	public function raw(send:RealStream<Chunk>):RealStream<Chunk> {
		throw '';
	}
	public function connect(send:RealStream<Chunk>):RealStream<Chunk> {
		throw '';
	}
	
	// public function connect(send:Stream<Bytes>):Stream<Bytes> {
	// 	return duplex.source.parse(IncomingHandshakeRequestHeader.parser()) >>
	// 		function(o:{data:IncomingHandshakeRequestHeader, rest:Source}):Stream<Bytes> {
	// 			switch o.data.validate() {
	// 				case Success(_): // ok
	// 				case Failure(f): return f;
	// 			}
				
	// 			var reponseHeader = new OutgoingHandshakeResponseHeader(o.data.key);
	// 			return (reponseHeader.toString():Source).pipeTo(duplex.sink) >>
	// 				function(_) {
	// 					// outgoing
	// 					send.forEachAsync(function(bytes) return (bytes:Source).pipeTo(duplex.sink).map(function(o) return true));
						
	// 					// incoming
	// 					return Success(o.rest.parseStream(new Parser()));
	// 				}
	// 		}
	// }
}
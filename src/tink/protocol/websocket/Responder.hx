package tink.protocol.websocket;

import haxe.io.Bytes;
import tink.io.Duplex;
import tink.io.Source;
import tink.streams.Stream;
import tink.protocol.Protocol;

using tink.CoreApi;

class Responder implements Protocol {
	
	var duplex:Duplex;
	
	public function new(duplex:Duplex) {
		this.duplex = duplex;
	}
	
	public function connect(send:Stream<Bytes>):Stream<Bytes> {
		return duplex.source.parse(IncomingHandshakeRequestHeader.parser()) >>
			function(o:{data:IncomingHandshakeRequestHeader, rest:Source}):Stream<Bytes> {
				switch o.data.validate() {
					case Success(_): // ok
					case Failure(f): return f;
				}
				
				var reponseHeader = new OutgoingHandshakeResponseHeader(o.data.key);
				return (reponseHeader.toString():Source).pipeTo(duplex.sink) >>
					function(_) {
						// outgoing
						send.forEachAsync(function(bytes) return (bytes:Source).pipeTo(duplex.sink).map(function(o) return true));
						
						// incoming
						return Success(o.rest.parseStream(new Parser()));
					}
			}
	}
}
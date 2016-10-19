package tink.protocol.websocket;

import tink.io.Duplex;
import tink.protocol.Client;

using tink.CoreApi;

class Server {
	public var connected:Signal<Client<Message>>;
}

class ServerClient implements Client<Message> {
	
	var duplex:Duplex;
	
	public function new(duplex:Duplex) {
		this.duplex = duplex;
	}
	
	public function connect(send:Stream<Message>):Stream<Message> {
		return duplex.source.parse(IncomingHandshakeRequestHeader.parser()).map(function(o) switch o {
			case Success({data: header, rest: rest}):
				switch header.validate() {
					case Success(_): // ok
					case Failure(f): return Failure(f);
				}
				
				// outgoing
				send.forEachAsync(function(message) return Frame.fromMessage(message).toSource().pipeTo(duplex.sink).map(function(o) return true));
				
				// incoming
				return Success(rest.parseStream(new Parser()));
				
			case Failure(e):
				return Failure(new Error('Cannot parse response header'));
		});
	}
}
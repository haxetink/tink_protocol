package tink.protocol.websocket;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.crypto.*;
import tink.url.Host;
import tink.http.Request;
import tink.http.Response;
import tink.http.Header;
import tink.Url;
import tink.io.Source;
import tink.io.Sink;
import tink.io.Duplex;
import tink.streams.Accumulator;
import tink.streams.Stream;
import tink.streams.StreamStep;
import tink.protocol.Protocol;
import tink.protocol.websocket.Parser;
import tink.protocol.websocket.Frame;
import tink.protocol.websocket.Message;

using tink.CoreApi;

class Requester implements Protocol {
	
	var duplex:Duplex;
	var host:Host;
	var uri:String;
	
	public function new(duplex:Duplex, url:Url) {
		this.duplex = duplex;
		this.host = url.host;
		this.uri = url.path;
	}
	
	public function connect(send:Stream<Bytes>):Stream<Bytes> {
		
		var header = new OutgoingHandshakeRequestHeader(host, uri);
		var accept = header.accept;
		(header.toString():Source).pipeTo(duplex.sink).handle(function(_) {});
		
		return duplex.source.parse(IncomingHandshakeResponseHeader.parser()).map(function(o) switch o {
			case Success({data: header, rest: rest}):
				switch header.validate(accept) {
					case Success(_): // ok
					case Failure(f): return Failure(f);
				}
				
				// outgoing
				send.forEachAsync(function(bytes) return (bytes:Source).pipeTo(duplex.sink).map(function(o) return true));
				
				// incoming
				return Success(rest.parseStream(new Parser()));
				
			case Failure(e):
				return Failure(new Error('Cannot parse response header'));
		});
	}
}
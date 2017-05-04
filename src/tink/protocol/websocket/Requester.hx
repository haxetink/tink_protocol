package tink.protocol.websocket;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.crypto.*;
import tink.url.Host;
import tink.http.Request;
import tink.http.Response;
import tink.http.Header;
import tink.Url;
import tink.io.Sink;
import tink.streams.Stream;
import tink.streams.RealStream;
import tink.protocol.Protocol;
import tink.protocol.websocket.Parser;
import tink.protocol.websocket.Frame;
import tink.protocol.websocket.Message;

using tink.io.Source;
using tink.CoreApi;

class Requester implements Protocol<Noise, Noise> {
	
	var source:RealSource;
	var sink:RealSink;
	var url:Url;
	
	public function new(source, sink, url) {
		this.source = source;
		this.sink = sink;
		this.url = url;
	}
	
	public function raw(send:RealStream<Chunk>):RealStream<Chunk> {
		
		var header = new OutgoingHandshakeRequestHeader(url.host, url.pathWithQuery);
		var accept = header.accept;
		var promise = (header.toString():IdealSource).pipeTo(sink).flatMap(function(o):Promise<RealStream<Chunk>> return switch o {
			case AllWritten:
				source.parse(IncomingHandshakeResponseHeader.parser()).flatMap(function(o):Promise<RealStream<Chunk>> switch o {
					case Success({a: header, b: rest}):
						switch header.validate(accept) {
							case Success(_): // ok
							case Failure(e): return e;
						}
						
						// outgoing
						send.forEach(function(chunk:Chunk) return (chunk:IdealSource).pipeTo(sink).map(function(o) return switch o {
							case AllWritten: Resume;
							case SinkEnded(_, _): Clog(new Error('Unexpected Sink End'));
							case SinkFailed(e, _): Clog(e);
						}));
						
						// incoming
						// return Success(rest.parse(new Parser()));
						throw '';
						
					case Failure(e):
						return new Error('Cannot parse response header');
				});
			case SinkEnded(_, _): new Error('Unexpected Sink End');
			case SinkFailed(e, _): e;
		});
		return cast Stream.promise(promise);
	}
	
	public function connect(send:RealStream<Noise>):RealStream<Noise> {
		throw '';
	}
}
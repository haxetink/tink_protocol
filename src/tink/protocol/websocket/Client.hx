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
import tink.protocol.Client as TinkClient;
import tink.protocol.websocket.Parser;
import tink.protocol.websocket.Frame;
import tink.protocol.websocket.Message;

using tink.CoreApi;

class Client implements TinkClient<Message, Message> {
	
	var protocol:TinkClient<Bytes, Bytes>;
	
	public function new(duplex:Duplex, url:Url) {
		this.protocol = new Protocol(duplex, url);
	}
	
	public function connect(send:Stream<Message>):Stream<Message> {
		
		// convert outgoing messages into bytes
		var key = Bytes.alloc(4); // message from client should always be masked (TODO: citation needed)
		var out = send.map(function(m) {
			for(i in 0...4) key.set(i, Std.random(0xff));
			return Frame.fromMessage(m, key).toBytes();
		});
		
		// combine and convert incoming bytes into messages
		return protocol.connect(out).merge(function(bytes):Option<Message> {
			var last = bytes[bytes.length - 1];
			if(last.get(0) >> 7 != 1) return None;
			
			var frames = [for(b in bytes) (b:Frame)];
			
			function mergeBytes() {
				if(frames.length == 1) return frames[0].payload;
				var out = new BytesBuffer();
				for(frame in frames) out.add(frame.payload);
				return out.getBytes();
			}
			
			return switch frames[0].opcode {
				case Continuation:
					throw 'Should not happen';
				case Text:
					Some(Text(mergeBytes().toString()));
				case Binary:
					Some(Binary(mergeBytes()));
				case ConnectionClose:
					Some(ConnectionClose);
				case Ping:
					Some(Ping(mergeBytes()));
				case Pong:
					Some(Pong(mergeBytes()));
			}
		});
	}
	
	public static function sender()
		return new Sender();
}

class Protocol implements TinkClient<Bytes, Bytes> {
	
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

class Sender extends Accumulator<Message> {
	public inline function send(m:Message) yield(Data(m));
}
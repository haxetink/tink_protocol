package tink.protocol.websocket;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.crypto.*;
import tink.url.Host;
import tink.tcp.Connection;
import tink.tcp.Endpoint;
import tink.http.Request;
import tink.http.Response;
import tink.http.Header;
import tink.Url;
import tink.io.Source;
import tink.io.Sink;
import tink.streams.Stream;
import tink.streams.StreamStep;
import tink.protocol.Client;
import tink.protocol.websocket.Parser;
import tink.protocol.websocket.Frame;
import tink.protocol.websocket.Message;

using tink.CoreApi;

class WebSocket implements Client<Message> {
	var protocol:Client<Bytes>;
	public function new(protocol:Client<Bytes>) {
		this.protocol = protocol;
	}
	
	public function connect(send:Stream<Message>):Stream<Message> {
		var out = send.map(function(m) return Frame.fromMessage(m).toBytes());
		return protocol.connect(out).merge(function(bytes):Option<Message> {
			var last:Frame = bytes[bytes.length - 1];
			if(!last.fin) return None;
			
			var frames = [for(b in bytes) (b:Frame)];
			
			function mergeBytes() {
				if(frames.length == 1) return frames[0].payload;
				var out = new BytesBuffer();
				for(frame in frames) out.addBytes(frame.payload, 0, frame.payload.length);
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

class ProtocolClient implements Client<Bytes> {
	
	var source:Source;
	var sink:Sink;
	var host:Host;
	var uri:Url;
	
	public function new(source:Source, sink:Sink, host:Host, uri:Url) {
		this.source = source;
		this.sink = sink;
		this.host = host;
		this.uri = uri;
	}
	
	public function connect(send:Stream<Bytes>):Stream<Bytes> {
		
		var key = Base64.encode(Sha1.make(Bytes.ofString(Std.string(Math.random()))));
		var accept = Base64.encode(Sha1.make(Bytes.ofString(key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")));
		var header = new OutgoingRequestHeader(GET, host, uri, [
			new HeaderField('Upgrade', 'websocket'),
			new HeaderField('Connection', 'Upgrade'),
			new HeaderField('Sec-WebSocket-Key', key),
			new HeaderField('Sec-WebSocket-Version', '13'),
		]);
		
		(header.toString():Source).pipeTo(sink).handle(function(_) {});
		
		return source.parse(ResponseHeader.parser()).map(function(o) switch o {
			case Success({data: header, rest: rest}):
				if(header.statusCode != 101) return Failure(new Error('Unexpected response status code'));
				switch header.byName('sec-websocket-accept') {
					case Success(v) if(v == accept):
					default: return Failure(new Error('Invalid accept'));
				}
				
				// outgoing
				send.forEachAsync(function(bytes) return (bytes:Source).pipeTo(sink).map(function(o) return true));
				
				// incoming
				return Success(rest.parseStream(new Parser()));
				
			case Failure(e):
				return Failure(new Error('Cannot parse response header'));
		});
	}
	
}

class Sender extends StepWise<Message> {
	
	var pending:List<FutureTrigger<StreamStep<Message>>>;
	var triggered:List<FutureTrigger<StreamStep<Message>>>;
	
	
	public function new() {
		pending = new List();
		triggered = new List();
	}
	
	override function next():Future<StreamStep<Message>> {
		return switch triggered.pop() {
			case null:
				var trigger = Future.trigger();
				pending.add(trigger);
				trigger;
			case trigger:
				trigger;
		}
	}
	
	public function send(message:Message) {
		var trigger = switch pending.pop() {
			case null:
				var trigger = Future.trigger();
				triggered.add(trigger);
				trigger;
			case trigger:
				trigger;
		}
		trigger.trigger(Data(message));
	}
}


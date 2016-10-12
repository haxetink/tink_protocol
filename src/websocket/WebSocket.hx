package websocket;

import haxe.io.BytesBuffer;
import haxe.io.Bytes;
import tink.url.Host;
import tink.streams.Stream;

interface Messenger {
	function connect(send:Stream<Bytes>):Stream<Bytes>;
}

class WebSocket implements Messenger {
	
	
	public function new(?host:Host) {
		
	}
	
	public function connect(send:Stream<Bytes>):Stream<Bytes> {
		return null;
	}
	
	function merge(frames:Stream<Frame>):Stream<Message> {
		return frames.merge(function(frames) {
			var last = frames[frames.length - 1];
			if(!last.fin) return None;
			
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
					Some(Ping);
				case Pong:
					Some(Pong);
			}
		});
	}
}

enum Message {
	Text(v:String);
	Binary(b:Bytes);
	ConnectionClose;
	Ping;
	Pong;
}


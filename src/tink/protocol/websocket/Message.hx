package tink.protocol.websocket;

import tink.Chunk;
import tink.streams.Stream;

using tink.CoreApi;

enum Message {
	Text(v:String);
	Binary(b:Chunk);
	ConnectionClose;
	Ping(b:Chunk);
	Pong(b:Chunk);
}

class MessageRegrouper {
	public static var inst:Regrouper<Frame, Message, Error> =
		function(frames:Array<Frame>, s) {
			var last = frames[frames.length - 1];
			if(!last.fin) return Untouched;
			
			function mergeBytes() {
				var out = Chunk.EMPTY;
				for(frame in frames) out = out & frame.unmaskedPayload;
				return out;
			}
			
			return Converted(Stream.single(switch frames[0].opcode {
				case Continuation:
					throw 'Unreachable'; // technically
				case Text:
					Message.Text(mergeBytes().toString());
				case Binary:
					Message.Binary(mergeBytes());
				case ConnectionClose:
					Message.ConnectionClose;
				case Ping:
					Message.Ping(mergeBytes());
				case Pong:
					Message.Pong(mergeBytes());
			}));
		}
}